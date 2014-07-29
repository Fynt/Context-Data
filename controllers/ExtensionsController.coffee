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
            blueprints: (blueprint.id for blueprint in blueprints)

          @respond
            extension: extensions
            blueprints: blueprints
          , false
    .catch (error) =>
      @abort 500

  find_action: ->
    @blueprint_manager.get_extensions()
    .then (results) =>
      for extension in results
        if extension == @params.id
          @blueprint_manager.get_blueprints
            extension: extension
          .then (blueprints) =>
            @respond
              extension:
                id: extension
                name: capitalize.words extension
                blueprints: (blueprint.id for blueprint in blueprints)
              blueprints: blueprints
            , false

            return # To exit out of the loop/function
        else
          @abort 404
    .catch (error) =>
      @abort 500
