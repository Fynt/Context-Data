Promise = require 'bluebird'
SearchAdapter = require '../Adapter'
search_index = require 'search-index'


module.exports = class SearchAdapterSearchIndex extends SearchAdapter

  constructor: (config) ->
    # We need to make sure the index has not already been opened.
    if not @constructor.search_index_opened?
      if config.server.search_index_path?
        @constructor.search_index_opened = true

        # The following configures where the search index actually goes.
        search_index.open config.server.search_index_path, (msg) ->
          console.info msg

  # @param data [Object]
  # @return [Promise]
  add: (data, ignore_fields=['id']) ->
    new Promise (resolve, reject) ->
      # Create a document name.
      id = data.id or Date.now()
      document_name = "data:#{id}"

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

  # @todo Will need to do some things to make the query object building a lot
  #   smarter.
  # @param query [String]
  # @return [Promise]
  find: (query) ->
    # Create the query Object that search-index expects.
    query_object =
      'query':
        '*': [query]

    new Promise (resolve, reject) ->
      search_index.search query_object, (result) ->
        documents = []
        for hit in result.hits
          documents.push hit['document']

        resolve documents

  # @return [Promise]
  info: ->
    new Promise (resolve, reject) ->
      search_index.tellMeAboutMySearchIndex (msg) ->
        resolve msg
