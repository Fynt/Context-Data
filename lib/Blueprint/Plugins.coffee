assert = require 'assert'
sequence = require 'when/sequence'

BlueprintPlugin = require './Plugin'


module.exports = class BlueprintPlugins

  # @param plugins [Array<BlueprintPlugin>]
  constructor: (@plugins=[]) ->

  # Register a plugin.
  #
  # @param plugin [BlueprintPlugin]
  register_plugin: (plugin) ->
    assert plugin instanceof BlueprintPlugin
    @plugins.push plugin

  # Will run each plugin in the order they were added to the plugins array, and
  #   will reject on the first failure or rejection from a plugin.
  #
  # @param event_type [String] The event type. Can be an arbitrary string, but
  #   must be a valid event handler name.
  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  event: (event_type, blueprint, item) ->
    promises = []

    # Populate the array of promises.
    for plugin in @plugins
      if plugin[event_type]?
        promises.push plugin[event_type] blueprint, item

    sequence promises, blueprint, item
