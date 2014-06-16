Controller = require '../lib/Controller'


module.exports = class BlueprintsController extends Controller

  initialize: ->
    @blueprint_manager = @server.blueprint_manager

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
