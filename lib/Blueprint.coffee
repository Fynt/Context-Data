BlueprintItem = require './Blueprint/Item'
BlueprintItemCollection = require './Blueprint/Item/Collection'


module.exports = class Blueprint

  # @params manager [BlueprintManager]
  # @param extension [String]
  # @param name [String]
  # @param definition [Object]
  constructor: (@manager, @extension, @name, @definition) ->

  # @return [Database]
  database: ->
    @manager.database()

  # @param item_data [Object] The row data.
  # @return [BlueprintItem]
  create: (item_data) ->
    item = new BlueprintItem @

    if item_data?
      item.initialize item_data

    item

  # Find one item by the item id
  #
  # @param data_id [Number]
  find_by_id: (data_id, callback) ->
    @find_one data_id, callback

  # Wrapper for find method with limit = 1
  #
  # @param filter [Number, Object]
  find_one: (filter, callback) ->
    @find filter, 1, (error, collection) ->
      # Doing this so that find_one will only return a single item.
      callback error, collection.pop()

  # Calls find with no limit.
  #
  # @param filter [Number, Object]
  find_all: (filter, callback) ->
    @find filter, null, callback

  # @param filter [Number, Object]
  find: (filter, limit, callback) ->
    @_find_query filter, limit, (error, results) =>
      callback error, @_collection_from_results results

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

  # @param item [BlueprintItem]
  destroy: (item, callback) ->
    callback error, item

  # @param item [BlueprintItem]
  # @param extension [String]
  # @param name [String]
  get_children_of_item: (item, extension, name, filter, callback) ->
    if item.id
      @manager.get_id extension, name, (error, child_blueprint_id) =>
        if child_blueprint_id
          q = @database().table 'data'
          .select 'data.*'
          .where 'data.blueprint_id', child_blueprint_id
          .join 'relationship', 'data.blueprint_id', '=',
          'relationship.child_blueprint_id'
          .andWhere 'relationship.parent_data_id', item.id

          q.exec (error, results) =>
            callback error, @_collection_from_results results
        else
          callback new Error 'Could not get a blueprint_id for child.', null
    else
      callback new Error 'Item has no id.', null

  # @param filter [Number, Object] An id or dictionary to filter the results.
  # @private
  _find_query: (filter, limit, callback) ->
    @manager.get_id @extension, @name, (error, blueprint_id) =>
      if blueprint_id
        q = @database().table 'data'

        if filter instanceof Object
          q.select 'data.*'
          .where 'data.blueprint_id', blueprint_id
          .join 'index', 'data.id', '=', 'index.data_id', 'inner'

          for key, value of filter
            q.andWhere 'index.key', key
            .andWhere 'index.value', value

          if limit?
            q.limit limit
        else
          q.where 'id', parseInt filter

        # For debugging...
        #console.log q.toString()

        q.exec callback

  # @private
  _insert_query: (item, callback) ->
    @manager.get_id @extension, @name, (error, blueprint_id) =>
      if blueprint_id
        @database().table 'data'
        .insert
          blueprint_id: blueprint_id
          data: item.json()
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
  _update_query: (item, callback) ->
    @manager.get_id @extension, @name, (error, blueprint_id) =>
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
  _create_indexes: (item) ->
    if item.id
      @manager.get_id @extension, @name, (error, blueprint_id) =>
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

  # @return [BlueprintItemCollection]
  _collection_from_results: (query_results) ->
    # Create and populate a collection.
    collection = new BlueprintItemCollection
    if query_results and query_results.length
      for result in query_results
        collection.push @create result

    collection
