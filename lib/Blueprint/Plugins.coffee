Promise = require 'bluebird'


module.exports = class BlueprintPlugins

  # @property [Array<BlueprintPlugin>]
  plugins: []

  # @param plugin [BlueprintPlugin]
  register_plugin: (plugin) ->
    @plugins.push plugin

  # @param blueprint [Blueprint]
  # @return [Promise]
  view: (blueprint) ->
    Promise.all [plugin.view blueprint for plugin in @plugins]

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  save: (blueprint, item) ->
    Promise.all [plugin.save blueprint, item for plugin in @plugins]

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  publish: (blueprint, item) ->
    Promise.all [plugin.publish blueprint, item for plugin in @plugins]

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  destroy: (blueprint, item) ->
    Promise.all [plugin.destroy blueprint, item for plugin in @plugins]
