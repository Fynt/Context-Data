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
    @find_one id: data_id, callback

  # Wrapper for find method with limit = 1
  find_one: (options, callback) ->
    @find options, 1, (error, collection) ->
      # Doing this so that find_one will only return a single item.
      callback error, collection.pop()

  find: (options, limit, callback) ->
    @_find_query options, limit, (error, results) =>

      # Create and populate a collection.
      collection = new BlueprintItemCollection
      for result in results
        collection.push @create result

      callback error, collection

  save: (item, callback) ->
    if not item.id?
      @_insert_query item, (error, data_id) ->
        item.id = data_id
        callback item
    else
      @_update_query item, (error, affected) ->
        callback item

  destroy: (item, callback) ->
    callback item

  # @private
  _find_query: (options, limit, callback) ->
    @manager.get_id @extension, @name, (error, blueprint_id) =>
      if blueprint_id
        @database().table 'data'
          .where options
          .andWhere 'blueprint_id', blueprint_id
          .limit limit
          .exec callback

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
