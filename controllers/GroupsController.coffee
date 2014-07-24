Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class GroupsController extends ApiController

  # @property [String]
  model_name: "group"

  # @property [Group]
  group_model: null

  initialize: ->
    database = @server.database()
    @group_model = Models(database.connection()).Group

  find_all_action: ->
    @group_model.fetchAll
      withRelated: ['permissions']
    .then (collection) =>
      permissions = []

      collection.mapThen (group) ->
        # Gives us on Object, which is easier to deal with.
        group = group.toJSON()

        # Append to the array of permissions.
        for permission in group.permissions
          permissions.push permission

        # Transform the data into what Ember needs for side-loading.
        group_permissions = group.permissions
        group.permissions = (p.id for p in group_permissions)

        group
      .then (collection) =>
        @respond
          group: collection
          permissions: permissions
        , false

  find_action: ->
    @group_model.forge
      id: @params.id
    .fetch
      withRelated: ['permissions']
    .then (group) =>
      if group
        # Gives us on Object, which is easier to deal with.
        group = group.toJSON()

        # Transform the data into what Ember needs for side-loading.
        permissions = group.permissions
        group.permissions = (p.id for p in permissions)

        @respond
          group: group
          permissions: permissions
        , false
      else
        @abort 404

  update_action: ->
    @group_model.forge
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
    @group_model.forge @request_body()
    .save()
    .then (group) =>
      @respond group
    .catch (error) =>
      @abort 500, error

  delete_action: ->
    @group_model.forge
      id: @params.id
    .destroy()
    .then (group) =>
      @respond group
