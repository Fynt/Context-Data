ApiController = require './ApiController'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class BlueprintsController extends ApiController

  # @property [String]
  model_name: "blueprint"

  # @property [Array<String>]
  valid_params = [
    'id', 'extension', 'name', 'slug'
  ]

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  add_definition_to_blueprint: (blueprint) ->
    blueprint.definition = @blueprint_manager.blueprint_definition(
      blueprint.extension, blueprint.name)

    blueprint

  find_all_action: ->
    params = {}
    for param in valid_params
      if @query[param]?
        params[param] = @query[param]

    @blueprint_manager.get_blueprints params
    .then (blueprints) =>
      blueprints.map @add_definition_to_blueprint, @
      @respond blueprints
    .catch (error) =>
      @abort 500, error

  find_action: ->
    @blueprint_manager.get_blueprint_by_id @params.id
    .then (blueprint) =>
      if not blueprint
        @abort 404
      else
        @respond @add_definition_to_blueprint blueprint
    .catch (error) =>
      @abort 500, error
