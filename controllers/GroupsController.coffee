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
    @group_model.fetchAll()
    .then (collection) =>
      @respond collection

  find_action: ->
    @group_model.forge
      id: @params.id
    .fetch()
    .then (group) =>
      if group
        @respond group
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
