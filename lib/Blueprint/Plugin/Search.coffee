BlueprintPlugin = require '../Plugin'


module.exports = class BlueprintPluginSearch extends BlueprintPlugin

  # @param search [Search]
  constructor: (@search) ->

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  pre_save: (blueprint, item) ->
    @search.add item

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  pre_destroy: (blueprint, item) ->
    @search.add item
