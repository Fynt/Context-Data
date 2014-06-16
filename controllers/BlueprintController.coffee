pluralize = require 'pluralize'
BlueprintsController = require './BlueprintsController'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintItemCollection = require '../lib/Blueprint/Item/Collection'


module.exports = class BlueprintController extends BlueprintsController

  # @property [Integer]
  default_limit: 100

  # @private
  # @param item_or_collection [BlueprintItem,BlueprintItemCollection]
  result: (item_or_collection) ->
    if item_or_collection instanceof BlueprintItemCollection
      collection = item_or_collection
      return @response.json collection.serialize()

    else if item_or_collection instanceof BlueprintItem
      item = item_or_collection
      data = item.serialize()

      # Apply relationship data
      item.relationship_ids (relationship_data) =>
        for key of relationship_data
          data[key] = relationship_data[key]

        return @response.json data

    else
      @respond item_or_collection

  # @return [Blueprint]
  get_blueprint: ->
    #TODO sanitize the strings a bit before passing them to the manager, because
    # who knows what require could do if there was a malicious file uploaded.
    extension = @params.extension
    name = pluralize.singular @params.name

    blueprint = @blueprint_manager.get extension, name

    if not blueprint?
      @abort 404

    blueprint

  definition_action: ->
    blueprint = @get_blueprint()
    @respond blueprint.definition

  find_all_action: ->
    blueprint = @get_blueprint()

    # Build the filter
    filter = {}
    for key in blueprint.keys
      if @query[key]?
        filter[key] = @query[key]

    # Get the limit
    limit = @query.limit or @default_limit

    # Get the results
    blueprint.find filter, limit, (error, results) =>
      if error
        @abort 500
      else
        @result results

  find_action: ->
    blueprint = @get_blueprint()
    blueprint.find_by_id @params.id, (error, result) =>
      if error
        @abort 500
      else
        @result result

  update_action: ->
    blueprint = @get_blueprint()
    blueprint.find_by_id @params.id, (error, item) =>
      if error
        return @abort 500

      if item
        for key in item.keys
          item.set key, @form[key]

        item.save (error, item) =>
          @result item
      else
        @abort 404

  create_action: ->
    blueprint = @get_blueprint()
    item = blueprint.create()

    for key in item.keys
      item.set key, @form[key]

    item.save (error, item) =>
      @result item

  delete_action: ->
    blueprint = @get_blueprint()
    blueprint.find_by_id @params.id, (error, item) =>
      if error
        return @abort 500

      if item
        item.destroy (error, item) =>
          @result item
      else
        @abort 404
