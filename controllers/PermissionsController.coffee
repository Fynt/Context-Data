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
    @permission_model.collection().query 'limit', @default_limit
    .fetch().then (collection) =>
      collection.mapThen (permission) ->
        permission.set 'group', permission.get 'group_id'
        permission.set 'blueprint', permission.get 'blueprint_id'
        permission.unset 'group_id'
        permission.unset 'blueprint_id'
      .then (collection) =>
        @respond collection
    .catch (error) =>
      @abort 500, error

  find_action: ->
    @permission_model.forge
      id: @params.id
    .fetch()
    .then (permission) =>
      if permission
        permission.set 'group', permission.get 'group_id'
        permission.set 'blueprint', permission.get 'blueprint_id'
        permission.unset 'group_id'
        permission.unset 'blueprint_id'

        @respond permission
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
    .then (permission) =>
      @respond permission
    .catch (error) =>
      @abort 500, error

  delete_action: ->
    @permission_model.forge
      id: @params.id
    .destroy()
    .then (permission) =>
      @respond permission
