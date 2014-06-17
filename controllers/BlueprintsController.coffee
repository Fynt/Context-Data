Controller = require '../lib/Controller'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class BlueprintsController extends Controller

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  find_all_action: ->
    extension = @params.extension
    @blueprint_manager.get_blueprints extension, (error, blueprints) =>
      if error
        return @abort 500

      if not blueprints
        return @abort 404

      definitions = {}
      for name in blueprints
        blueprint = @blueprint_manager.get extension, name
        definitions[name] = blueprint.definition

      @respond definitions
