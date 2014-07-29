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

  find_all_action: ->
    params = {}
    for param in valid_params
      if @query[param]?
        params[param] = @query[param]

    @blueprint_manager.get_blueprints params
    .then (blueprints) =>
      @respond blueprints
    .catch (error) =>
      @abort 500, error

  find_action: ->
    @blueprint_manager.get_extension_and_name_by_id @params.id
    .then (blueprint_row) =>
      if not blueprint_row
        @abort 404
      else
        extension = blueprint_row.extension
        name = blueprint_row.name
        @respond @blueprint_manager.get extension, name
    .catch (error) =>
      @abort 500, error
