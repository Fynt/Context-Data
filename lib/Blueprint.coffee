BlueprintItem = require './Blueprint/Item'


module.exports = class Blueprint

  constructor: (@manager, @extension, @name) ->

  # @return [Database]
  database: ->
    @manager.database()

  find_one: (options, callback) ->
    @find options, 1, callback

  find: (options, limit, callback) ->
    @query options, limit, (error, results) ->
      console.log error, results

  create: (data) ->
    new BlueprintItem @

  save: (item, callback) ->
    if not item.id?
      @_insert_query()

    callback item

  destroy: (item, callback) ->
    callback item

  # @private
  _find_query: (options, limit, callback) ->
    @manager.get_id @extension, @name, (error, blueprint_id) ->
      if blueprint_id
        @database.table 'data'
          .where options
          .andWhere 'blueprint_id', blueprint_id
          .limit limit
          .exec callback

  # @private
  _insert_query: ->
    console.log "INSERT!"
