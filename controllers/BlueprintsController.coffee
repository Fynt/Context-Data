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

      @respond blueprints
    .catch (error) =>
      @abort 500, error
