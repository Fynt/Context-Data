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
      promises = []

      for result in results
        extension =
          id: result
          name: capitalize.words result

        promise = @blueprint_manager.get_blueprints
          extension: result
        promise.then (blueprints) ->
          extension['blueprints'] = (blueprint.id for blueprint in blueprints)
        promises.push promise

        extensions.push extension

      Promise.all(promises).then =>
        @respond
          extension: extensions
        , false
    .catch (error) =>
      @abort 500, error

  find_action: ->
    @blueprint_manager.get_extensions()
    .then (results) =>
      # Yep, we loop through them to find the matching id. Stop judging!
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

          return # To exit out of the loop.

      # If we got here, it means we couldn't find the extension in the results.
      @abort 404
    .catch (error) =>
      @abort 500
