capitalize = require 'capitalize'
Controller = require '../lib/Controller'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class ExtensionsController extends Controller

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  find_all_action: ->
    @blueprint_manager.get_extensions()
    .then (results) =>
      id = 1
      extensions = []

      for extension in results
        @blueprint_manager.get_blueprints extension
        .then (blueprints) =>
          extensions.push
            id: id++
            name: capitalize.words extension
            slug: extension
            blueprints: blueprints

          @respond extensions
    .catch (error) =>
      @abort 500
