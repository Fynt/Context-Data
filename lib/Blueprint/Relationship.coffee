BlueprintItemCollection = require './Item/Collection'


module.exports = class BlueprintRelationship

  # @private
  # @property
  _collection: null

  # @param item [BlueprintItem] The item that this relationship is a property
  #   of.
  # @param type [String] The relationship type
  # @param related [String] The extension/name of the related blueprint.
  constructor: (@item, type, related) ->
    @blueprint = @item.blueprint
    @related_blueprint = @blueprint.get_related related

    @adapter = @load_adapter type

  # Will lazy load the collection.
  collection: (callback) ->
    if @_collection
      callback @_collection
    else
      @all (collection) ->
        @_collection = collection
        callback collection

  # @param related_item [BlueprintItem]
  add: (related_item, callback) ->
    @item.get_id (error, id) ->
      if error
        callback error, @item, related_item

      related_item.get_id (error, related_id) ->
        if error
          callback error, @item, related_item

        if id and related_id
          @adaper.add_relationship id, related_id ->
            callback null, @item, related_item

  all: (callback) ->
    @find null, null, callback

  # @param filter [Number, Object]
  one: (filter, callback) ->
    @find filter, 1

  # @param filter [Number, Object]
  # @param limit [Number]
  find: (filter, limit, callback) ->
    callback new BlueprintItemCollection [1..10]

  # Allows you to iterate over the collection.
  #
  # @param fn [Function] The function to call for each item in the collection.
  forEach: (fn) ->
    @collection (collection) ->
      last_index = collection.length - 1
      for i in [0..last_index]
        fn i, collection.get(i), collection

  # @private
  # @param type [String] The adapter type
  load_adapter: (relationship_type) ->
    # Generate a class name from the type
    upper = (word) ->
      word[0].toUpperCase() + word[1..-1].toLowerCase()
    class_name = (relationship_type.split('_').map (word) -> upper word).join ''

    # Create class name
    adapter_class = require "./Relationship/Adapter/#{class_name}"
    adapter = new adapter_class @

    # Return the adapter
    adapter
