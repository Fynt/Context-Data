Promise = require 'bluebird'
capitalize = require 'capitalize'
ApiController = require './ApiController'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class ExtensionsController extends ApiController

  # @property [String]
  model_name: 'extension'

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  add_definition_to_blueprint: (blueprint) ->
    blueprint.definition = @blueprint_manager.blueprint_definition(
      blueprint.extension, blueprint.name)

    blueprint

  find_all_action: ->
    @blueprint_manager.get_extensions()
    .then (results) =>
      extensions = []
      blueprints = {}

      promises = []
      for extension in results
        promise = @blueprint_manager.get_blueprints
          extension: extension
        .then (blueprints_for_extension) ->
          # Extension is really just a key, but ember prefers to treat it like
          # a traditional model, so we're sort of faking it!
          extensions.push
            id: extension
            name: capitalize.words extension
            blueprints: (blueprint.id for blueprint in blueprints_for_extension)

          for blueprint in blueprints_for_extension
            blueprints[blueprint.id] = blueprint

        promises.push promise

      Promise.all(promises).then =>
        unique_blueprints = (blueprints[key] for key of blueprints)
        unique_blueprints.map @add_definition_to_blueprint, @

        @respond
          extension: extensions
          blueprints: unique_blueprints
        , false
    .catch (error) =>
      @abort 500, error

  find_action: ->
    @blueprint_manager.get_extensions()
    .then (results) =>
      for extension in results
        if extension == @params.id
          @blueprint_manager.get_blueprints
            extension: extension
          .then (blueprints) =>
            blueprints.map @add_definition_to_blueprint, @

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
