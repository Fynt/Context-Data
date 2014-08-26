si = require 'search-index'
Promise = require 'bluebird'
SearchAdapter = require '../Adapter'


module.exports = class SearchAdapterSearchIndex extends SearchAdapter

  constructor: (config) ->
    console.log si
    if config.server.search_index_path?
      si.open config.server.search_index_path, (msg) ->

  # @param data [Object]
  # @return [Promise]
  add: (data, ignore_fields=[]) ->
    new Promise (resolve, reject) ->
      si.add data, 'lol', ignore_fields, (msg) ->
        resolve msg

  # @param id [String]
  # @return [Promise]
  get: (id) ->
    new Promise (resolve, reject) ->
      si.get id, (result) ->
        resolve result

  # @param id [String]
  # @return [Promise]
  del: (id) ->
    new Promise (resolve, reject) ->
      si.del id, (result) ->
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
      si.search query, (msg) ->
        resolve msg

  info: ->
    new Promise (resolve, reject) ->
      si.tellMeAboutMySearchIndex (msg) ->
        resolve msg
