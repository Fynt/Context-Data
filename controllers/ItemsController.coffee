Promise = require 'bluebird'
pluralize = require 'pluralize'
BlueprintsController = require './BlueprintsController'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintItemCollection = require '../lib/Blueprint/Item/Collection'


# Extends BlueprintsController so it gets an instance of the manager.
module.exports = class ItemsController extends BlueprintsController

  # @property [String]
  model_name: "item"

  # @private
  # @param item_or_collection [BlueprintItem,BlueprintItemCollection]
  result: (item_or_collection) ->
    extension = @params.extension

    if item_or_collection instanceof BlueprintItemCollection
      collection = item_or_collection
      return @respond collection.serialize()

    else if item_or_collection instanceof BlueprintItem
      item = item_or_collection
      data = item.serialize()

      # Apply relationship data
      item.relationship_ids (relationship_data) =>
        for key of relationship_data
          data[key] = relationship_data[key]

        return @respond data
    else
      @respond item_or_collection

  # Will determine which blueprint you need based on the type of request.
  #
  # @param item_id [Integer] If provided, can be used to determine the
  #   blueprint.
  # @return [Promise]
  get_blueprint: (item_id=null) ->
    load_blueprint = (extension=null, blueprint_name=null) =>
      @extension_name = extension if extension?
      @blueprint_name = blueprint_name if blueprint_name?
      @blueprint_manager.get @extension_name, @blueprint_name

    new Promise (resolve, reject) =>
      # We might already have the extension and blueprint names.
      if @extension_name and @blueprint_name
        resolve load_blueprint()

      # Try and get the blueprint based on the slug.
      else if @query.extension and @query.blueprint_slug
        @blueprint_manager.get_extension_and_name_by_slug @query.extension,
          @query.blueprint_slug
        .then (result) ->
          resolve load_blueprint(result.extension, result.name)

      # Otherwise get it from the item id
      else if item_id?
        @blueprint_manager.get_extension_and_name_by_item_id item_id
        .then (result) ->
          resolve load_blueprint(result.extension, result.name)

      # Otherwise it might be defined in the request body.
      else if @request.body['item']?
        blueprint_id = @request.body['item']['blueprint']
        @blueprint_manager.get_extension_and_name_by_id blueprint_id
        .then (result) ->
          resolve load_blueprint(result.extension, result.name)

      else
        reject new Error "There was no way to know which blueprint you want."

  before_action: ->
    # Make sure the following are reset before each request.
    @extension_name = null
    @blueprint_name = null

    # Get the extension and blueprint names from the route.
    if @params.extension and @params.name
      #TODO todo sanitize the strings a bit before passing them to the manager,
      # because who knows what require could do if there was a malicious file
      # uploaded.
      @extension_name = @params.extension
      @blueprint_name = pluralize.singular @params.name

  definition_action: ->
    @get_blueprint()
    .then (blueprint) =>
      @response.json blueprint.definition
    .catch (error) =>
      @abort 500, error

  find_all_action: ->
    @get_blueprint()
    .then (blueprint) =>
      # Build the filter
      filter = {}
      if blueprint?
        for key in blueprint.keys
          if @query[key]?
            filter[key] = @query[key]

      # Get the limit
      limit = @query.limit or @default_limit

      # Get the results
      blueprint.find filter, limit, (error, results) =>
        if error
          @abort 500, error
        else
          @result results
    .catch (error) =>
      @abort 500, error

  find_action: ->
    @get_blueprint @params.id
    .then (blueprint) =>
      blueprint.find_by_id @params.id, (error, result) =>
        if error
          @abort 500
        else
          @result result
    .catch (error) =>
      @abort 500, error

  update_action: ->
    @get_blueprint()
    .then (blueprint) =>
      blueprint.find_by_id @params.id, (error, item) =>
        if error
          return @abort 500, error

        if item
          item_data = @request.body['item']
          for key in item.keys
            item.set key, item_data[key]

          item.save (error, item) =>
            @result item
        else
          @abort 404
    .catch (error) =>
      @abort 500, error

  create_action: ->
    @get_blueprint()
    .then (blueprint) =>
      item = blueprint.create()

      item_data = @request.body['item']
      for key in item.keys
        item.set key, item_data[key] if item_data[key]?

      item.save (error, item) =>
        @result item
    .catch (error) =>
      @abort 500, error

  delete_action: ->
    @get_blueprint @params.id
    .then (blueprint) =>
      blueprint.find_by_id @params.id, (error, item) =>
        if error
          return @abort 500, error

        if item
          item.destroy (error, item) =>
            @result item
        else
          @abort 404
    .catch (error) =>
      @abort 500, error
