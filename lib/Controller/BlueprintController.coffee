pluralize = require 'pluralize'
Controller = require '../Controller'


module.exports = class BlueprintController extends Controller

  # @param server [Server] The Server instance
  # @param blueprint_manager [BlueprintManager]
  constructor: (@server, @blueprint_manager) ->

  get_blueprint: ->
    extension = @params.extension
    name = pluralize.singular @params.name

    @blueprint_manager.get extension, name

  find_all_action: ->
    @respond "find_all"

  find_action: ->
    @respond "find"

  update_action: ->
    @respond "update"

  create_action: ->
    @respond "create"

  delete_action: ->
    @respond "delete"
