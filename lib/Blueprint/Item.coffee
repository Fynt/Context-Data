Observable = require '../Observable'
BlueprintRelationship = require './Relationship'

RELATIONSHIP_TYPES = ['belongs_to', 'has_many', 'has_one']


module.exports = class BlueprintItem extends Observable

  # @property [Integer]
  id: null

  # @property [Array<String>]
  keys: []

  # @property [Array<String>]
  relationships: []

  # @property [Object]
  data: {}

  # @property
  published: false

  # @param blueprint [Blueprint]
  constructor: (@blueprint) ->
    @keys = @blueprint.keys

    @_register_properties @blueprint.definition

    @initialize()

    @add_observer @

  # @param item_row [Object] The row from the database to restore the item.
  # @return [BlueprintItem] For chaining
  initialize: (item_row) ->
    if item_row?
      @id = item_row.id
      # Make sure we aren't overwriting @data with null.
      if item_row.data?
        @populate JSON.parse(item_row.data)
      @published = item_row.published

    @

  # Not to be confused with initialize as this method only deals with the data
  # property.
  #
  # @param data [Object]
  populate: (data) ->
    @data = data

  # Save the item
  save: (callback) ->
    @blueprint.save @, (error, item) =>
      # Update with the new id.
      @id = item.id if item and item.id?

      @notify "save"
      callback error, item

  # Delete the item
  destroy: (callback) ->
    @blueprint.destroy @, (error, item) =>
      @notify "delete"
      callback error, item

  # Gets an id.
  #
  # Better than just accessing the `id` property in some cases, because this
  # method will force a save if needed to generate an id.
  get_id: (callback) ->
    if @id?
      callback null, @id
    else
      @save (error, item) ->
        callback error, item.id

  # Convenience method for setting published to true.
  publish: ->
    @published = true

  # Convenience method for setting published to false.
  unpublish: ->
    @published = false

  # @param key [String]
  # @return [String]
  get: (key, fallback=null) ->
    @data[key] or fallback

  # @param key [String]
  set: (key, value=null) ->
    @data[key] = value

  # Serialize the BlueprintItem as a simple Object. Call @json() if you need a
  #   String.
  #
  # @return [Object]
  serialize: ->
    data =
      id: @id
      published: @published

    for key in @keys
      data[key] = @data[key]

    data

  # @return [String]
  json: ->
    JSON.stringify @serialize()

  # Gets all the ids that represent the relationships.
  relationship_ids: (callback) ->
    data = {}
    loaded_relationships = 0

    if not @relationships.length
      callback data
    else
      for relationship in @relationships
        @[relationship].find_ids (error, ids) =>
          loaded_relationships++
          data[relationship] = ids

          # Gosh I hope this is not as flaky as it looks.
          if loaded_relationships >= @relationships.length
            callback data

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
      for relationship in RELATIONSHIP_TYPES
        if value instanceof Object and value[relationship]?
          # Register the relationship
          @relationships.push key

          # Add a property to the item instance
          related = value[relationship]
          @[key] = new BlueprintRelationship @, relationship, related

    Object.defineProperties @, properties
