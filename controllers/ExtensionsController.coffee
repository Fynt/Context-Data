Controller = require '../lib/Controller'


module.exports = class ExtensionsController extends Controller

  initialize: ->
    @blueprint_manager = @server.blueprint_manager

  find_all_action: ->
    extension = @params.extension
    @blueprint_manager.get_extensions (error, extensions) =>
      if error
        return @abort 500

      @respond extensions
