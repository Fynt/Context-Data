Promise = require 'bluebird'
SearchAdapter = require '../Adapter'
search_index = require 'search-index'


module.exports = class SearchAdapterSearchIndex extends SearchAdapter

  # @param config [Object]
  constructor: (config) ->
    # We need to make sure the index has not already been opened.
    if not @constructor.search_index_opened?
      if config.server.search_index_path?
        @constructor.search_index_opened = true

        # The following configures where the search index actually goes.
        search_index.open config.server.search_index_path, (msg) ->
          console.info msg

  # @param data [BlueprintItem, Model]
  # @param ignore_fields [Array<String>]
  # @return [Promise]
  add: (data, ignore_fields) ->
    # Get the document name.
    document_name = @get_name data

    # Create the data container.
    document_data = {}
    document_data[document_name] = @serialize data

    new Promise (resolve, reject) ->
      # Add the data to the index (will perform an update if the document name
      # already exists).
      search_index.add document_data, document_name, ignore_fields, (msg) ->
        resolve msg

  # @param data [BlueprintItem, Model]
  # @return [Promise]
  del: (data) ->
    # Get the document name.
    document_name = @get_name data

    new Promise (resolve, reject) ->
      search_index.del document_name, (result) ->
        resolve result

  # @param query [String]
  # @return [Promise]
  find: (query) ->
    query_object = {}

    # Parse that query string.
    if query.indexOf(":") > 0
      query_array = query.toLowerCase().split ":"
      query_object[query_array[0].trim()] = [query_array[1].trim()]
    else
      query_object['*'] = [query.toLowerCase()]

    # Create the query Object that search-index expects.
    query_container =
      'query': query_object

    new Promise (resolve, reject) ->
      search_index.search query_container, (result) ->
        documents = {}
        for hit in result.hits
          type = hit.id.split(":")[0]

          if not documents[type]?
            documents[type] = []

          documents[type].push hit['document']

        resolve documents

  # @return [Promise]
  info: ->
    new Promise (resolve, reject) ->
      search_index.tellMeAboutMySearchIndex (msg) ->
        resolve msg
