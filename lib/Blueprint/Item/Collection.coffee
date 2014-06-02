module.exports = class BlueprintItemCollection

  # The count of items in the collection.
  #
  # @private
  # @property [Number]
  length: 0

  # @param items [Array<BlueprintItem>] An array of items
  constructor: (@items=[]) ->
    @length = @items.length

  # @param index [Number]
  # @return [BlueprintItem]
  get: (index) ->
    @items[index]

  # Adds an item to the collection.
  #
  # @param item [BlueprintItem]
  push: (item) ->
    @items.push item
    @length = @items.length

    @items

  # Removes and returns an item from the collection.
  #
  # @return [BlueprintItem]
  pop: ->
    item = @items.pop()
    @length = @items.length

    item

  # Allows you to iterate over the collection.
  #
  # @param fn [Function] The function to call for each item in the collection.
  forEach: (fn) ->
    last_index = @length - 1
    for i in [0..last_index]
      fn i, @get(i), @

  # @return [String]
  json: ->
    item_list = []
    for item in items
      item_list.push item

    JSON.stringify item_list
