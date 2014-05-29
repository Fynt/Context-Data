BlueprintItemCollection = require '../Item/Collection'


# @abstract
module.exports = class BlueprintRelationshipAdapter

  _collection: null

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
