pluralize = require 'pluralize'
Controller = require '../lib/Controller'


module.exports = class BlueprintsController extends Controller

  initialize: ->
    @blueprint_manager = @server.blueprint_manager

  # @return [Blueprint]
  get_blueprint: ->
    #TODO sanitize the strings a bit before passing them to the manager, because
    # who knows what require could do if there was a malicious file uploaded.
    extension = @params.extension
    name = pluralize.singular @params.name

    blueprint = @blueprint_manager.get extension, name

    if not blueprint?
      @abort 404

    blueprint

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
