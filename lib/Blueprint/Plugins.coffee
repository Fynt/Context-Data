assert = require 'assert'
w = require 'when'

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
    next = (i) -> ++i
    predicate = (i) => i >= @plugins.length
    handler = (i) =>
      plugin = @plugins[i]
      if plugin and plugin[event_type]?
        return plugin[event_type] blueprint, item

    w.iterate next, predicate, handler, 0
