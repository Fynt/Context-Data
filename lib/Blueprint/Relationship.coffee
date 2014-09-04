Models = require '../Models'
BlueprintItemCollection = require './Item/Collection'


module.exports = class BlueprintRelationship

  # @property [BlueprintRelationshipAdapter]
  adapter: null

  # @private
  # @property [BlueprintItemCollection]
  _collection: null

  # @param item [BlueprintItem] The item that this relationship is a property
  #   of.
  # @param relationship_type [String] The relationship type
  # @param related [String] The extension/name of the related blueprint.
  constructor: (@item, relationship_type, related) ->
    @blueprint = @item.blueprint

    # TODO There should be a cleaner way of doing this.
    try
      @related = @blueprint.get_blueprint related
      relationship_type = "#{relationship_type}_item"
    catch
      @related = Models(@database().connection())[related]
      relationship_type = "#{relationship_type}_model"

    @adapter = @load_adapter relationship_type

  # Gets an instance of the database
  #
  # @return [Database]
  database: ->
    @blueprint.database()

  # Will lazy load the collection.
  collection: (callback) ->
    if @_collection
      callback @_collection
    else
      @all (error, collection) ->
        @_collection = collection
        callback collection

  # @param related_item [BlueprintItem]
  add: (related_item, callback) ->
    @item.get_id (error, id) =>
      if error
        callback error, @item, related_item

      related_item.get_id (error, related_id) =>
        if error
          callback error, @item, related_item

        if id and related_id
          @adapter.add related_item, =>
            callback null, @item, related_item

  all: (callback) ->
    @find null, null, callback

  # @param filter [Integer, Object]
  one: (filter, callback) ->
    @find filter, 1

  # @param filter [Integer, Object]
  # @param limit [Integer]
  find: (filter, limit, callback) ->
    @adapter.find filter, limit, callback

  # Gets all of the ids that represent the related items. Useful for serializing
  #  the relationship.
  find_ids: (callback) ->
    @adapter.find_ids (error, results) ->
      ids = []
      for result in results
        ids.push result.id

      callback error, ids

  # Allows you to iterate over the collection.
  #
  # @param fn [Function] The function to call for each item in the collection.
  forEach: (fn) ->
    @collection (collection) ->
      last_index = collection.length - 1
      for i in [0..last_index]
        fn i, collection.get(i), collection

  # @private
  # @param relationship_type [String] The relationship adapter type
  load_adapter: (relationship_type) ->
    # Generate a class name from the type
    upper = (word) ->
      word[0].toUpperCase() + word[1..-1].toLowerCase()
    class_name = (relationship_type.split('_').map (word) -> upper word).join ''

    # Create class name
    adapter_class = require "./Relationship/Adapter/#{class_name}"
    adapter = new adapter_class @, @item

    # Return the adapter
    adapter
