Controller = require '../lib/Controller'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class ExtensionsController extends Controller

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  find_all_action: ->
    extension = @params.extension

    @blueprint_manager.get_extensions()
    .then (extensions) =>
      @respond extensions
    .catch (error) =>
      @abort 500
