pluralize = require 'pluralize'
Controller = require '../lib/Controller'


module.exports = class BlueprintController extends Controller

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

  find_all_action: ->
    limit = @params.limit or 100

    blueprint = @get_blueprint()
    blueprint.find {}, limit, (error, results) =>
      if error
        @abort 500
      else
        @respond results

  find_action: ->
    blueprint = @get_blueprint()
    blueprint.find_by_id @params.id, (error, result) =>
      if error
        @abort 500
      else
        @respond result

  update_action: ->
    blueprint = @get_blueprint()
    blueprint.find_by_id @params.id, (error, item) =>
      if error
        return @abort 500

      if item
        for key in item.keys
          item.set key, @form[key]

        item.save (error, item) =>
          @respond item
      else
        @abort 404

  create_action: ->
    blueprint = @get_blueprint()
    item = blueprint.create()

    for key in item.keys
      item.set key, @form[key]

    item.save (error, item) =>
      @respond item

  delete_action: ->
    blueprint = @get_blueprint()
    blueprint.find_by_id @params.id, (error, item) =>
      if error
        return @abort 500

      if item
        item.destroy (error, item) =>
          @respond item
      else
        @abort 404
