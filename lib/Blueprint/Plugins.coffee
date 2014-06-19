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
  # @param event [String]
  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  on: (event, blueprint, item) ->
    index = 0
    length = @plugin.length
    results = []

    p = Promise.pending()

    run_plugin = ->
      if index >= length - 1
        p.fulfill results

      if @plugin[index][event]?
        @plugin[index][event] blueprint, item
        .then (result) ->
          results.push result
          run_plugin
        .error (error) ->
          p.reject error
        .catch (error) ->
          p.reject error
      else
        run_plugin

      index++

    p.promise
