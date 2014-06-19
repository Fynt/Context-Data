assert = require 'assert'
Promise = require 'bluebird'
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
  # @todo There might be a more efficient way to call all the plugins, but I
  #   feel like the following code gives us more control, and we are certain of
  #   the execution order.
  # @param event_type [String] The event type. Can be an arbitrary string, but
  #   must be a valid event handler name.
  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  event: (event_type, blueprint, item) ->
    index = 0
    length = @plugins.length
    results = []

    p = Promise.pending()

    # Recursive function for executing each plugin.
    run_plugin = =>
      # Check if we've called all the plugins. This is basically a no-op if the
      # length is 0.
      if not length or index >= length - 1
        p.fulfill results

      # Get the plugin
      plugin = @plugins[index]
      index++

      # If the plugin and event handler exists...
      if plugin and [event_type]?
        # Call the handler.
        plugin[event_type] blueprint, item
        .then (result) ->
          results.push result
          run_plugin()

        # Note the the following cases will reject the promise, and will not
        # continue the loop.
        .error (error) ->
          p.reject error
        .catch (error) ->
          p.reject error

      # Otherwise continue to the next plugin.
      else
        run_plugin()

    run_plugin()


    # Return the promise.
    p.promise
