BlueprintRelationship = require './Relationship'

RELATIONSHIPS = ['belongs_to', 'has_many', 'has_one']


module.exports = class BlueprintItem

  # @property
  id: null

  # @property
  data: {}

  # @property
  published: false

  # @param blueprint [Blueprint]
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

  # Gets an id.
  #
  # Better than just accessing the `id` property in some cases, because this
  # method will force a save if needed to generate an id.
  get_id: (callback) ->
    if @id?
      callback null, id
    else
      @save error, item ->
        callback error, item.id

  # @param key [String]
  # @return [String]
  get: (key, fallback=null) ->
    @data[key] or fallback

  # @param key [String]
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

      # Apply relationships
      for relationship in RELATIONSHIPS
        if value instanceof Object and value[relationship]?
          @[key] = new BlueprintRelationship @ relationship

    Object.defineProperties @, properties
