module.exports = class ModelItem

  # @property [Object]
  data: {}

  # @param db [Model]
  constructor: (@model) ->

  # @param item_row [Object] The row from the database to restore the item.
  # @return [ModelItem] For chaining
  initialize: (item_row) ->

    @

  # @param key [String]
  # @return [String]
  get: (key, fallback=null) ->
    @data[key] or fallback

  # @param key [String]
  set: (key, value=null) ->
    @data[key] = value
