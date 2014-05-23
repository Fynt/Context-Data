module.exports = class BlueprintItemCollection

  constructor: (@items=[]) ->

  push: (item) ->
    @items.push item

  pop: ->
    @items.pop()

  # @return String
  json: ->
    item_list = []
    for item in items
      item_list.push item

    JSON.stringify item_list
