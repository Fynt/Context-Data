_ = require 'lodash'
Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class HistoryController extends ApiController

  # @property [String]
  model_name: "history"

  # 100 is too much for ember model?
  default_limit: 50

  # @property [History]
  history_model: null

  initialize: ->
    database = @server.database()
    @history_model = Models(database.connection()).History

  load_all: (q) ->
    q.fetch
      withRelated: ['blueprint']
    .then (collection) =>
      collection.mapThen (history) ->
        history = history.toJSON()

        history.extension = history.blueprint.extension
        history.blueprint_slug = history.blueprint.slug
        history.blueprint_name = history.blueprint.name

        delete history.blueprint

        history
      .then (collection) =>
        @respond collection
    .catch (error) =>
      @abort 500, error

  find_all_action: ->
    q = @history_model.collection()
    .query 'limit', @default_limit
    .query 'orderBy', 'id', 'desc'

    if not _.isEmpty @query
      q.query (knex) =>
        knex.innerJoin('data', 'history.data_id', '=', 'data.id')
        .innerJoin('blueprint', 'data.blueprint_id', '=', 'blueprint.id')

        # @query in this case refers to the query params.
        for key of @query
          if key == "extension"
            knex.where 'blueprint.extension', @query[key]
          else if key == "blueprint_slug"
            knex.where 'blueprint.slug', @query[key]
          else if key == "blueprint_name"
            knex.where 'blueprint.name', @query[key]

        @load_all q
    else
      @load_all q

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
