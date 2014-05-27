module.exports = class BlueprintItemCollection

  # @param items [Array<BlueprintItem>] An array of items
  constructor: (@items=[]) ->

  # @param item [BlueprintItem]
  push: (item) ->
    @items.push item

  # @return [BlueprintItem]
  pop: ->
    @items.pop()

  # @return [String]
  json: ->
    item_list = []
    for item in items
      item_list.push item

    JSON.stringify item_list
