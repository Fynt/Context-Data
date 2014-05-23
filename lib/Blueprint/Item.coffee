module.exports = class BlueprintItem

  # @property
  @id = null

  # @property
  @data = {}

  # @property
  @published = false

  constructor: (@blueprint) ->
    @initialize()

  # @param item_data [Object]
  # @return [BlueprintItem] For chaining
  initialize: (item_data) ->
    if item_data?
      @id = item_data.id
      @data = JSON.parse item_data.data
      @published = item_data.published

    @

  save: (callback) ->
    @blueprint.save @, callback

  destroy: (callback) ->
    @blueprint.destroy @, callback

  get: (key, fallback=null) ->
    @data[key] or fallback

  set: (key, value=null) ->
    @data[key] = value

  # @return [String]
  json: ->
    JSON.stringify @data
