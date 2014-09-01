Promise = require 'bluebird'
pluralize = require 'pluralize'
BlueprintsController = require './BlueprintsController'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintItemCollection = require '../lib/Blueprint/Item/Collection'


# Extends BlueprintsController so it gets an instance of the manager.
module.exports = class ItemsController extends BlueprintsController

  # This guy is dynamic.
  #
  # @property [String]
  model_name: null

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

  # @return [Blueprint]
  get_blueprint: ->
    blueprint_slug = pluralize.singular @params.blueprint_slug
    @model_name = "#{@params.extension}/#{blueprint_slug}"

    @blueprint_manager.get @params.extension, @params.blueprint_slug

  # @todo Uggh, some duplicate code here.
  before_action: ->
    blueprint_slug = pluralize.singular @params.blueprint_slug
    @model_name = "#{@params.extension}/#{blueprint_slug}"

  find_all_action: ->
    blueprint = @get_blueprint()
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

        # Get the ordering
        sort_by = @query.sort_by or null
        sort_order = @query.sort_order or null

        # Get the results
        blueprint.find filter, limit, sort_by, sort_order, (error, results) =>
          if error
            @abort 500, error
          else
            @result results
      else
        @abort 401

  find_action: ->
    blueprint = @get_blueprint()
    @check_permissions(blueprint, 'view').then (is_allowed) =>
      if is_allowed
        blueprint.find_by_id @params.id, (error, item) =>
          if error
            @abort 500, error
          else
            @result item
      else
        @abort 401

  update_action: ->
    blueprint = @get_blueprint()
    @check_permissions(blueprint, 'save').then (is_allowed) =>
      if is_allowed
        blueprint.find_by_id @params.id, (error, item) =>
          if error
            return @abort 500, error

          if item
            # Set the author.
            item.author = @user_id()

            # Apply the posted data.
            item_data = @request.body[@model_name]
            for key in item.keys
              item.set key, item_data[key]

            item.save (error, item) =>
              @result item
          else
            @abort 404
      else
        @abort 401

  create_action: ->
    blueprint = @get_blueprint()
    @check_permissions(blueprint, 'save').then (is_allowed) =>
      if is_allowed
        item = blueprint.create()

        # Set the author.
        item.author = @user_id()

        # Apply the posted data.
        item_data = @request.body[@model_name]
        for key in item.keys
          item.set key, item_data[key] if item_data[key]?

        item.save (error, item) =>
          @result item
      else
        @abort 401

  delete_action: ->
    blueprint = @get_blueprint @params.id
    @check_permissions(blueprint, 'destroy').then (is_allowed) =>
      if is_allowed
        blueprint.find_by_id @params.id, (error, item) =>
          if error
            return @abort 500, error

          if item
            # Set the author. For reasons.
            item.author = @user_id()

            item.destroy (error, item) =>
              @result item
          else
            @abort 404
      else
        @abort 401
