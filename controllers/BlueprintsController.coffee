Controller = require '../lib/Controller'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class BlueprintsController extends Controller

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  find_all_action: ->
    extension = @params.extension
    @blueprint_manager.get_blueprints extension
    .then (blueprints) =>
      if not blueprints or not blueprints.length
        return @abort 404

      definitions = {}
      for name in blueprints
        try
          blueprint = @blueprint_manager.get extension, name
          definitions[name] = blueprint.definition

      @respond definitions
    .catch (error) =>
      console.log error
      return @abort 500
