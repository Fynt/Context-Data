pluralize = require 'pluralize'
Controller = require '../lib/Controller'


module.exports = class BlueprintController extends Controller

  initialize: ->
    @blueprint_manager = @server.blueprint_manager

  # @return [BlueprintManager]
  get_blueprint: ->
    extension = @params.extension
    name = pluralize.singular @params.name

    blueprint = @blueprint_manager.get extension, name

    if not blueprint?
      @abort 404

    blueprint

  find_all_action: ->
    limit = @params.limit or 100

    manager = @get_blueprint()
    manager.find {}, limit, (error, results) =>
      if error
        @abort 500
      else
        @respond results

  find_action: ->
    manager = @get_blueprint()
    manager.find_by_id @params.id, (error, results) =>
      if error
        @abort 500
      else
        @respond results

  update_action: ->
    @get_blueprint()
    @respond "update"

  create_action: ->
    @get_blueprint()
    @respond "create"

  delete_action: ->
    @get_blueprint()
    @respond "delete"
