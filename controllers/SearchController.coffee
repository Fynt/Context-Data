Search = require '../lib/Search'
Controller = require '../lib/Controller'


module.exports = class SearchController extends Controller

  initialize: ->
    @search = new Search @server.config

  search_action: ->
    @search.find @query.q
    .then (results) =>
      @respond results
