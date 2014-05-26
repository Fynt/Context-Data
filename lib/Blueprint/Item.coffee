module.exports = class BlueprintItem

  # @property
  id: null

  # @property
  data: {}

  # @property
  published: false

  constructor: (@blueprint) ->
    @_register_properties @blueprint.definition

    @initialize()

  # @param item_data [Object]
  # @return [BlueprintItem] For chaining
  initialize: (item_data) ->
    if item_data?
      @id = item_data.id
      # Make sure we aren't overwriting @data with null.
      if item_data.data?
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

  # @private
  # @param definition [Object]
  _register_properties: (definition) ->
    properties = {}

    for key, value of definition
      if value instanceof Object and value.type?
        do (key) ->
          properties[key] =
            get: ->
              @get key
            set: (value) ->
              @set key, value

      if value instanceof Object and value.has_many?
        do (key) =>
          @[key] = ->
            @blueprint.get_related value.has_many

    Object.defineProperties @, properties
