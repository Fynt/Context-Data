module.exports = class BlueprintPlugins

  # @property [Array<BlueprintPlugin>]
  plugins: []

  # @param plugin [BlueprintPlugin]
  register_plugin: (plugin) ->
    @plugins.push plugin

  # @param blueprint [Blueprint]
  # @return [Boolean]
  view: (blueprint) ->
    for plugin in @plugins
      result = plugin.view blueprint
      return false if result == false

    true

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Boolean]
  save: (blueprint, item) ->
    for plugin in @plugins
      result = plugin.save blueprint, item
      return false if result == false

    true

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Boolean]
  publish: (blueprint, item) ->
    for plugin in @plugins
      result = plugin.publish blueprint, item
      return false if result == false

    true

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Boolean]
  destroy: (blueprint, item) ->
    for plugin in @plugins
      result = plugin.destroy blueprint, item
      return false if result == false

    true
