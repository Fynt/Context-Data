BlueprintItem = require './Blueprint/Item'
BlueprintItemCollection = require './Blueprint/Item/Collection'


module.exports = class Blueprint

  constructor: (@manager, @extension, @name) ->

  # @return [Database]
  database: ->
    @manager.database()

  # @return [BlueprintItem]
  create: (item_data) ->
    item = new BlueprintItem @

    if item_data?
      item.initialize item_data

    item

  find_by_id: (data_id, callback) ->
    @find_one data_id, callback

  # Wrapper for find method with limit = 1
  find_one: (filter, callback) ->
    @find filter, 1, (error, collection) ->
      # Doing this so that find_one will only return a single item.
      callback error, collection.pop()

  find: (filter, limit, callback) ->
    @_find_query filter, limit, (error, results) =>

      # Create and populate a collection.
      collection = new BlueprintItemCollection
      if results and results.length
        for result in results
          collection.push @create result

      callback error, collection

  save: (item, callback) ->
    if not item.id?
      @_insert_query item, (error, data_id) =>
        item.id = data_id
        callback item

        @_create_indexes item
    else
      @_update_query item, (error, affected) =>
        callback item

        @_create_indexes item

  destroy: (item, callback) ->
    callback item

  # @param filter [Number, Object] An id or dictionary to filter the results.
  # @private
  _find_query: (filter, limit, callback) ->
    @manager.get_id @extension, @name, (error, blueprint_id) =>
      if blueprint_id
        q = @database().table('data').limit limit

        if filter instanceof Object
          q.select 'data.*'
          .where 'data.blueprint_id', blueprint_id
          .join 'index', 'data.id', '=', 'index.data_id', 'inner'

          for key, value of filter
            q.andWhere 'index.key', key
            .andWhere 'index.value', value
        else
          q.where 'data_id', parseInt filter

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
          callback error, ids[0]
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
    @manager.get_id @extension, @name, (error, blueprint_id) =>
      if blueprint_id
        # Make sure we delete the existing indexes
        @database().table 'index'
        .where 'data_id', item.id
        .del().exec (error, affected) =>
          # Build the array of data
          indexes = []
          for key, value of item.data
            indexes.push
              data_id: item.id
              blueprint_id: blueprint_id
              key: key
              value: value

          # Insert away!
          @database().table 'index'
          .insert indexes
          .exec()
      else
        callback new Error 'Could not get a blueprint_id.', null
