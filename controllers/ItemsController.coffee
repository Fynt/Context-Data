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
  # @todo There has to be a cleaner way to figure out blueprints.
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

      # Get the blueprint from the blueprint id.
      else if @query.blueprint
        @blueprint_manager.get_blueprint_by_id @query.blueprint
        .then (result) ->
          resolve load_blueprint(result.extension, result.name)

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
          if result
            resolve load_blueprint(result.extension, result.name)
          else
            reject new Error "Item doesn not exist."

      # Otherwise it might be defined in the request body.
      else if @request.body['item']?
        blueprint_id = @request.body['item']['blueprint']
        @blueprint_manager.get_blueprint_by_id blueprint_id
        .then (result) ->
          resolve load_blueprint(result.extension, result.name)

      else
        reject new Error "There was no way to know which blueprint you want."

  definition_action: ->
    @get_blueprint()
    .then (blueprint) =>
      @response.json blueprint.definition
    .catch (error) =>
      @abort 500, error

  find_all_action: ->
    @get_blueprint().then (blueprint) =>
      @check_permissions(blueprint, 'view').then (is_allowed) =>
        if is_allowed
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
        else
          @abort 401
      .catch (error) =>
        @abort 500, error

  find_action: ->
    @get_blueprint @params.id
    .then (blueprint) =>
      @check_permissions(blueprint, 'view').then (is_allowed) =>
        if is_allowed
          blueprint.find_by_id @params.id, (error, item) =>
            if error
              @abort 500, error
            else
              @result item
        else
          @abort 401
    .catch (error) =>
      @abort 500, error

  update_action: ->
    @get_blueprint()
    .then (blueprint) =>
      @check_permissions(blueprint, 'save').then (is_allowed) =>
        if is_allowed
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
        else
          @abort 401
    .catch (error) =>
      @abort 500, error

  create_action: ->
    @get_blueprint()
    .then (blueprint) =>
      @check_permissions(blueprint, 'save').then (is_allowed) =>
        if is_allowed
          item = blueprint.create()

          item_data = @request.body['item']
          for key in item.keys
            item.set key, item_data[key] if item_data[key]?

          item.save (error, item) =>
            @result item
        else
          @abort 401
    .catch (error) =>
      @abort 500, error

  delete_action: ->
    @get_blueprint @params.id
    .then (blueprint) =>
      @check_permissions(blueprint, 'destroy').then (is_allowed) =>
        if is_allowed
          blueprint.find_by_id @params.id, (error, item) =>
            if error
              return @abort 500, error

            if item
              item.destroy (error, item) =>
                @result item
            else
              @abort 404
        else
          @abort 401
    .catch (error) =>
      @abort 500, error
