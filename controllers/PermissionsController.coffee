Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class PermissionsController extends ApiController

  # @property [String]
  model_name: "permission"

  # @property [Permission]
  permission_model: null

  initialize: ->
    database = @server.database()
    @permission_model = Models(database.connection()).Permission

  find_all_action: ->
    @permission_model.fetchAll()
    .then (collection) =>
      @respond collection

  find_action: ->
    @permission_model.forge
      id: @params.id
    .fetch()
    .then (group) =>
      if group
        @respond group
      else
        @abort 404

  update_action: ->
    @permission_model.forge
      id: @params.id
    .fetch()
    .then (group) =>
      if group
        group.set(@request_body()).save()
        .then (group) =>
          @respond group
      else
        @abort 404

  create_action: ->
    @permission_model.forge @request_body()
    .save()
    .then (group) =>
      @respond group
    .catch (error) =>
      @abort 500, error

  delete_action: ->
    @permission_model.forge
      id: @params.id
    .destroy()
    .then (group) =>
      @respond group
