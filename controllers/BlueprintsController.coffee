pluralize = require 'pluralize'
Controller = require '../lib/Controller'


module.exports = class BlueprintsController extends Controller

  initialize: ->
    @blueprint_manager = @server.blueprint_manager

  # @return [Blueprint]
  get_blueprint: ->
    extension = @params.extension
    name = pluralize.singular @params.name

    blueprint = @blueprint_manager.get extension, name

    if not blueprint?
      @abort 404

    blueprint
