capitalize = require 'capitalize'
ApiController = require './ApiController'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class ExtensionsController extends ApiController

  # @property [String]
  model_name: 'extension'

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  find_all_action: ->
    @blueprint_manager.get_extensions()
    .then (results) =>
      extensions = []

      for extension in results
        @blueprint_manager.get_blueprints
          extension: extension
        .then (blueprints) =>
          # Extension is really just a key, but ember prefers to treat it like
          # a traditional model, so we're sort of faking it!
          extensions.push
            id: extension
            name: capitalize.words extension
            #TODO Figure out why Ember can't deal with the full blueprint.
            blueprints: (blueprint.id for blueprint in blueprints)

          @respond extensions
    .catch (error) =>
      @abort 500
