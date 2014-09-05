Promise = require 'bluebird'
BlueprintItem = require './Blueprint/Item'
BlueprintHistoryManager = require './Blueprint/HistoryManager'
BlueprintItemCollection = require './Blueprint/Item/Collection'


module.exports = class Blueprint

  # @property [Array<String>]
  keys: []

  # @private
  # @property [BlueprintPlugins]
  plugins: null

  # @params manager [BlueprintManager]
  # @param extension [String]
  # @param name [String]
  # @param definition [Object]
  constructor: (@manager, @extension, @name, @definition) ->
    @plugins = @manager.plugins
    @history_manager = new BlueprintHistoryManager @database()

    # Get the valid keys from the definition.
    @keys = []
    for key, value of @definition
      if value instanceof Object and value.type?
        @keys.push key

  # Gets an instance of the database
  #
  # @return [Database]
  database: ->
    @manager.database()

  # Convenience method for getting the blueprint id from the manager.
  #
  # @param callback [Function]
  get_id: (callback) ->
    @manager.get_id @extension, @name
    .then (id) ->
      callback null, id

  # Gets the slug name.
  #
  # @return [String]
  get_slug: ->
    @manager._blueprint_slug @name

  get_permission_resource: ->
    "#{@extension}:#{@name}"

  # Creates a BlueprintItem.
  #
  # @param item_data [Object] The row data.
  # @return [BlueprintItem]
  create: (item_data) ->
    item = new BlueprintItem @
    item.add_observer @history_manager

    if item_data?
      item.initialize item_data

    item

  # Find one item by the item id
  #
  # @param data_id [Integer]
  # @param callback [Function]
  find_by_id: (data_id, callback) ->
    @find_one data_id, callback

  # Wrapper for find method with limit = 1
  #
  # @param filter [Integer, Object]
  # @param callback [Function]
  find_one: (filter, callback) ->
    @find filter, 1
    .then (collection) ->
      callback null, collection.pop()
    .catch (error) ->
      callback error, null

  # Calls find with no limit.
  #
  # @param filter [Integer, Object]
  # @param callback [Function]
  find_all: (filter, callback) ->
    @find filter
    .then (collection) ->
      callback null, collection
    .catch (error) ->
      callback error, null

  # Finds a collection of items based on filter and limit.
  #
  # @param filter [Integer, Object]
  # @param limit [Integer]
  # @param sort_by [String]
  # @param sort_order [String]
  # @return [Promise]
  find: (filter, limit, sort_by=null, sort_order=null) ->
    new Promise (resolve, reject) =>
      @plugins.event 'pre_view', @
      .then =>
        @_find_query filter, limit, sort_by, sort_order, (error, results) =>
          resolve @_collection_from_results results
      .catch (error) ->
        reject error

  # Saves an item.
  #
  # @param item [BlueprintItem]
  # @param callback [Function]
  save: (item, callback) ->
    if not item.id?
      @_insert_query item, (error, data_id) =>
        if data_id
          item.id = data_id
          @_create_indexes item

        callback error, item
    else
      @_update_query item, (error, affected) =>
        @_create_indexes item

        callback error, item

  # Deletes an item.
  #
  # @param item [BlueprintItem]
  # @param callback [Function]
  destroy: (item, callback) ->
    if not item.id?
      # There was nothing to destroy.
      callback null, item
    else
      @_delete_query item, (error, affected) =>
        # Make sure the delete cascades so we don't have orphaned data.
        @_destroy_indexes item
        @_destroy_relationships item

        callback error, item

  # Gets a blueprint, but makes the assumption that you are loading it within
  # the same extension.
  #
  # @param name [String]
  # @param extension [String]
  # @return [Blueprint]
  get_blueprint: (name, extension) ->
    # The following lets us allow relationships across extensions. Fun!
    if name.indexOf("/") > 0
      extension_and_name = name.split("/")

      extension = extension_and_name[0]
      name = extension_and_name[1]
    else
      if not extension?
        # Assume the current extension should be used.
        extension = @extension

    @manager.get extension, name

  # @private
  # @param filter [Integer, Object] An id or dictionary to filter the results.
  # @param limit [Integer]
  # @param sort_by [String]
  # @param sort_order [String]
  # @param callback [Function]
  _find_query: (filter, limit, sort_by, sort_order, callback) ->
    @get_id (error, blueprint_id) =>
      if error
        callback error, null

      if blueprint_id
        q = @database().table 'data'
        .select 'data.*'
        .where 'data.blueprint_id', blueprint_id

        if filter instanceof Object
          if filter.ids?
            q.whereIn 'data.id', filter.ids
            delete filter.ids

          # Make sure there's actually something in the filter object.
          if Object.keys(filter).length
            q.innerJoin 'index as i', 'data.id', 'i.data_id'

            for key, value of filter
              if @keys.indexOf(key) > -1
                q.andWhere 'i.key', key
                .andWhere 'i.value', value
              else
                q.andWhere key, value
        else if parseInt filter
          q.where 'id', parseInt filter

        if sort_by?
          if @keys.indexOf(sort_by) > -1
            q.innerJoin 'index as s', 'data.id', 's.data_id'
            .andWhere 's.key', sort_by
            .orderBy 's.value', sort_order
          else
            # Add a standard orderBy clause for the native table fields.
            q.orderBy sort_by, sort_order

        if limit?
          q.limit limit

        q.exec callback
      else
        callback new Error 'Could not get a blueprint_id.', null

  # @private
  # @param item [BlueprintItem]
  # @param callback [Function]
  _insert_query: (item, callback) ->
    @get_id (error, blueprint_id) =>
      if blueprint_id
        @database().table 'data'
        .insert
          blueprint_id: blueprint_id
          data: item.json(true)
          published: item.published
          author: item.author
          created_at: new Date
        .exec (error, ids) ->
          if ids and ids.length
            id = ids[0]
          else
            id = null

          callback error, id
      else
        callback new Error 'Could not get a blueprint_id.', null

  # @private
  # @param item [BlueprintItem]
  # @param callback [Function]
  _update_query: (item, callback) ->
    @get_id (error, blueprint_id) =>
      if blueprint_id
        @database().table 'data'
        .where 'id', item.id
        .update
          data: item.json(true)
          published: item.published
          author: item.author
          updated_at: new Date
        .exec (error, affected) ->
          callback error, affected
      else
        callback new Error 'Could not get a blueprint_id.', null

  # @private
  # @param item [BlueprintItem]
  # @param callback [Function]
  _delete_query: (item, callback) ->
    @get_id (error, blueprint_id) =>
      if blueprint_id
        q = @database().table 'data'
        .del()
        .where 'id', item.id
        .where 'blueprint_id', blueprint_id
        .limit 1

        q.exec (error, affected) ->
          callback error, affected
      else
        callback new Error 'Could not get a blueprint_id.', null

  # @private
  # @param item [BlueprintItem]
  _create_indexes: (item) ->
    if item.id
      @get_id (error, blueprint_id) =>
        if blueprint_id
          # Make sure we delete the existing indexes
          @database().table 'index'
          .where 'data_id', item.id
          .del().exec (error, affected) =>
            # Build the array of data
            indexes = []

            for key, value of item.data
              if key and value
                indexes.push
                  data_id: item.id
                  blueprint_id: blueprint_id
                  key: key
                  value: value

            if indexes.length
              # Insert away!
              @database().table 'index'
              .insert indexes
              .exec()

  # @private
  # @param item [BlueprintItem]
  _destroy_indexes: (item) ->
    if item.id
      @database().table 'index'
      .where 'data_id', item.id
      .del().exec (error, affected) ->

  # @private
  # @param item [BlueprintItem]
  _destroy_relationships: (item) ->
    if item.id
      @database().table 'relationship'
      .where 'parent_data_id', item.id
      .orWhere 'child_data_id', item.id
      .del().exec (error, affected) ->

  # Takes raw query_results (rows) and turns them into an item collection.
  #
  # @private
  # @return [BlueprintItemCollection]
  _collection_from_results: (query_results) ->
    # Create and populate a collection.
    collection = new BlueprintItemCollection
    if query_results and query_results.length
      for result in query_results
        collection.push @create result

    collection
