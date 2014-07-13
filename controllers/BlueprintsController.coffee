ApiController = require './ApiController'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class BlueprintsController extends ApiController

  valid_params = [
    'id', 'extension', 'name', 'slug'
  ]

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  find_all_action: ->
    params = {}
    for param in valid_params
      if @query[param]?
        params[param] = @query[param]

    @blueprint_manager.get_blueprints params
    .then (blueprints) =>
      @respond blueprints, 'blueprints'
    .catch (error) =>
      @abort 500, error
