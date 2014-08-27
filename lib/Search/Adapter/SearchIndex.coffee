Promise = require 'bluebird'
SearchAdapter = require '../Adapter'
search_index = require 'search-index'


module.exports = class SearchAdapterSearchIndex extends SearchAdapter

  constructor: (config) ->
    # The following configures where the search index actually goes.
    if config.server.search_index_path?
      search_index.open config.server.search_index_path, (msg) ->
        console.info msg

  # @param data [Object]
  # @return [Promise]
  add: (data, ignore_fields=['id']) ->
    new Promise (resolve, reject) ->
      # Create a document name.
      id = data.id or Date.now()
      document_name = "document:#{id}"

      # Create the data container.
      document_data = {}
      document_data[document_name] = data

      # Add the data to the index.
      search_index.add document_data, document_name, ignore_fields, (msg) ->
        resolve msg

  # @param id [String]
  # @return [Promise]
  get: (id) ->
    new Promise (resolve, reject) ->
      search_index.get id, (result) ->
        resolve result

  # @param id [String]
  # @return [Promise]
  del: (id) ->
    new Promise (resolve, reject) ->
      search_index.del id, (result) ->
        resolve result

  # @param query [String, Object]
  # @return [Promise]
  find: (query) ->
    if query instanceof String
      # Create the query Object that search-index expects.
      query =
        'query':
          '*': query

    new Promise (resolve, reject) ->
      search_index.search query, (msg) ->
        resolve msg

  # @return [Promise]
  info: ->
    new Promise (resolve, reject) ->
      search_index.tellMeAboutMySearchIndex (msg) ->
        resolve msg
