Controller = require '../lib/Controller'


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

  # @param result [Object, String] The value you want to send.
  respond: (result) ->
    if not @model_name
      throw new Error "You'll need to supply a model name."

    model_result = {}
    model_result[@model_name] = result

    @response.json model_result

  # Gets the item data from the request based on the model_name.
  #
  # @return [Object]
  request_body: ->
    if not @model_name?
      throw new Error "The model_name must be set in the controller."

    @request.body[@model_name]
