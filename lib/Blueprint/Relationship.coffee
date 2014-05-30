BlueprintItemCollection = require './Item/Collection'


module.exports = class BlueprintRelationship

  _collection: null

  constructor: (@item, relationship_type) ->
    @adapter = @load_adapter relationship_type

  # Will lazy load the collection.
  collection: (callback) ->
    if @_collection
      callback @_collection
    else
      @all (collection) ->
        @_collection = collection
        callback collection

  all: (callback) ->
    @find null, null, callback

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
    new adapter_class
