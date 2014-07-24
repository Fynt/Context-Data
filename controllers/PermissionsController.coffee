Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class PermissionsController extends ApiController

  # @property [String]
  model_name: "permission"

  # @property [Permission]
  permission_model: null

  # An array of keys representing the model properties that can be updated
  #   through the API.
  #
  # @property [Array<String>]
  mutable_fields: [
    'group_id'
    'type'
    'resource'
    'action'
    'is_allowed'
  ]

  initialize: ->
    database = @server.database()
    @permission_model = Models(database.connection()).Permission

  # @return [Object]
  permission_data: ->
    request_body = @request_body()

    # Set the group id properly.
    if request_body.group?
      request_body.group_id = parseInt request_body.group

    # Set the blueprint id properly.
    if request_body.blueprint?
      request_body.blueprint_id = parseInt request_body.blueprint

    # Populate the permission_data object.
    permission_data = {}
    for field in @mutable_fields
      if request_body[field]?
        permission_data[field] = request_body[field]

    permission_data

  find_all_action: ->
    @permission_model.collection().query 'limit', @default_limit
    .fetch().then (collection) =>
      collection.mapThen (permission) ->
        permission.set 'group', permission.get 'group_id'
        permission.unset 'group_id'
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
        permission.unset 'group_id'

        @respond permission
      else
        @abort 404

  update_action: ->
    @permission_model.forge
      id: @params.id
    .fetch()
    .then (permission) =>
      if permission
        permission.set(@permission_data()).save()
        .then (permission) =>
          @respond permission
      else
        @abort 404

  create_action: ->
    @permission_model.forge @permission_data()
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
