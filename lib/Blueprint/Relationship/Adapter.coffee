BlueprintItemCollection = require '../Item/Collection'


# @abstract
module.exports = class BlueprintRelationshipAdapter

  _collection: null

  collection: ->
    if not @_collection?
      #TODO call find()
      @_collection = new BlueprintItemCollection [1..10]

    @_collection

  find: (filter=null) ->

  # @param fn [Function] The function to call for each item in the collection.
  forEach: (fn) ->
    collection = @collection()

    last_index = collection.length - 1
    for i in [0..last_index]
      fn i, collection.get(i), collection
