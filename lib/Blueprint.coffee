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
  find_by_id: (data_id, callback) ->
    @find_one data_id, callback

  # Wrapper for find method with limit = 1
  #
  # @param filter [Integer, Object]
  find_one: (filter, callback) ->
    @find filter, 1, (error, collection) ->
      # Doing this so that find_one will only return a single item.
      callback error, collection.pop()

  # Calls find with no limit.
  #
  # @param filter [Integer, Object]
  find_all: (filter, callback) ->
    @find filter, null, callback

  # Finds a collection of items based on filter and limit.
  #
  # @param filter [Integer, Object]
  # @param limit [Integer]
  find: (filter, limit, callback) ->
    @plugins.event 'pre_view', @
    .then =>
      @_find_query filter, limit, (error, results) =>
        callback error, @_collection_from_results results
    .catch (error) =>
      callback error, @_collection_from_results

  # Saves an item.
  #
  # @param item [BlueprintItem]
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
    if not extension?
      extension = @extension

    @manager.get extension, name

  # @private
  # @param filter [Integer, Object] An id or dictionary to filter the results.
  # @param limit [Integer]
  _find_query: (filter, limit, callback) ->
    @get_id (error, blueprint_id) =>
      if error
        callback error, null

      if blueprint_id
        q = @database().table 'data'
        .where 'data.blueprint_id', blueprint_id

        if filter instanceof Object
          if Object.keys(filter).length
            q.select 'data.*'
            .innerJoin 'index', 'data.id', 'index.data_id'

            for key, value of filter
              q.andWhere 'index.key', key
              .andWhere 'index.value', value
        else if parseInt filter
          q.where 'id', parseInt filter

        if limit?
          q.limit limit

        q.exec callback
      else
        callback new Error 'Could not get a blueprint_id.', null

  # @private
  # @param item [BlueprintItem]
  _insert_query: (item, callback) ->
    @get_id (error, blueprint_id) =>
      if blueprint_id
        @database().table 'data'
        .insert
          blueprint_id: blueprint_id
          data: item.json true
          published: item.published
          author: 1
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
  _update_query: (item, callback) ->
    @get_id (error, blueprint_id) =>
      if blueprint_id
        @database().table 'data'
        .where 'id', item.id
        .update
          data: item.json()
          published: item.published
          author: 1
          updated_at: new Date
        .exec (error, affected) ->
          callback error, affected
      else
        callback new Error 'Could not get a blueprint_id.', null

  # @private
  # @param item [BlueprintItem]
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
