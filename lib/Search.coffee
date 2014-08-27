module.exports = class Search

  # @private
  # @property adapter [SearchAdapter]
  adapter: null

  # @param config [Object] The Application config
  constructor: (config) ->
    if config.server.search_adapter?
      adapter_name = config.server.search_adapter
      @load_adapter adapter_name, config
    else
      throw new Error "Search class requires a `search_adapter` setting in the"
      + " server config."

  # @private
  # @param adapter_name [String]
  # @param config [Object] The Application config
  # @return [SearchAdapter]
  load_adapter: (adapter_name, config) ->
    adapter_class = require "./Search/Adapter/#{adapter_name}"
    @adapter = new adapter_class config

  # @param data [Object]
  # @return [Promise]
  add: (data) ->
    @adapter.add data

  # @param id [String]
  # @return [Promise]
  get: (id) ->
    @adapter.get id

  # @param id [String]
  # @return [Promise]
  del: (id) ->
    @adapter.del id

  # @param query [String]
  # @return [Promise]
  find: (query) ->
    @adapter.find query

  # @return [Promise]
  info: ->
    @adapter.info()
