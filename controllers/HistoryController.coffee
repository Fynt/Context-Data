Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class HistoryController extends ApiController

  # @property [String]
  model_name: "history"

  # @property [History]
  history_model: null

  initialize: ->
    database = @server.database()
    @history_model = Models(database.connection()).History

  find_all_action: ->
    @history_model.fetchAll()
    .then (collection) =>
      @respond collection
    .catch (error) =>
      @abort 500, error

  find_action: ->
    @history_model.forge
      id: @params.id
    .fetch()
    .then (history) =>
      if history
        @respond history
      else
        @abort 404

  update_action: ->
    @history_model.forge
      id: @params.id
    .fetch()
    .then (history) =>
      if history
        history.set(@request_body()).save()
        .then (history) =>
          @respond history
      else
        @abort 404

  create_action: ->
    @history_model.forge @request_body()
    .save()
    .then (history) =>
      @respond history
    .catch (error) =>
      @abort 500, error

  delete_action: ->
    @history_model.forge
      id: @params.id
    .destroy()
    .then (history) =>
      @respond history
