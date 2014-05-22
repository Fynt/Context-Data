module.exports = class BlueprintItem

  id: null
  data: {}

  constructor: (@blueprint) ->

  initialize: (id=null, data={}) ->
    @id = id
    @data = data

  save: ->
    @blueprint.save @

  destroy: ->
    @blueprint.destroy @

  get: (key, fallback=null) ->
    @_data[key] or fallback

  set: (key, value=null) ->
    @_data[key] = value

  json: ->
    JSON.stringify @data
