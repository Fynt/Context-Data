module.exports = class BlueprintItem

  @id = null
  @data = {}
  @published = false

  constructor: (@blueprint) ->
    @initialize()

  # @return [BlueprintItem] For chaining
  initialize: (id=null, data={}, published=false) ->
    @id = id
    @data = data
    @published = published

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
