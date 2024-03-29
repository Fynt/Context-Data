Controller = require '../lib/Controller'
Permissions = require '../lib/Permissions'


module.exports = class ApiController extends Controller

  # To be set in child classes.
  #
  # @abstract
  # @property [String]
  model_name: null

  # Used to set the default limits for query results.
  #
  # @property [Integer]
  default_limit: 100

  constructor: (@server) ->
    @permissions = new Permissions @server.database()
    super @server

  # Sends an API response.
  #
  # @param result [Object, String] The value you want to send.
  # @param transform [Boolean] Determines if the result should be wrapped in a
  #   hash for Ember.
  respond: (result, transform=true) ->
    if not @model_name
      throw new Error "You'll need to supply a model name."

    if transform
      model_result = {}
      model_result[@model_name] = result

      @response.json model_result
    else
      @response.json result

  # Gets the item data from the request based on the model_name.
  #
  # @return [Object]
  request_body: ->
    if not @model_name?
      throw new Error "The model_name must be set in the controller."

    @request.body[@model_name]

  # Provides a convenience method to check permissions.
  #
  # @return [Promise]
  check_permissions: (asset, action) ->
    @permissions.is_allowed @user_id(), asset, action

  # Returns the current user id or null.
  #
  # @return [Integer]
  user_id: ->
    @session.user_id or null

  # Given an array of items with an id, this method will reduce the set to
  #   unique items.
  #
  # @param objects [Array<Object>]
  # @return [Array<Object>]
  remove_duplicates: (objects) ->
    unique_objects = {}
    for object in objects
      unique_objects[object.id] = object

    # Now return the array of values from the hash.
    (unique_objects[key] for key of unique_objects)
