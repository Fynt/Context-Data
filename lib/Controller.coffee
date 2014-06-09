BlueprintItem = require './Blueprint/Item'
BlueprintItemCollection = require './Blueprint/Item/Collection'


# The base Controller class
#
# @abstract
module.exports = class Controller

  # @param server [Server] The Server instance
  constructor: (@server) ->
    @initialize()

  # Provides a hook to do controller specific initialization.
  #
  # @abstract
  initialize: ->

  # Called by the application when dispatching a request.
  #
  # @param [String] action The action you want called.
  # @private
  call_action: (action, request, response) ->
    # Set some values on the controller instance that the action might want to
    # reference.
    @params = request.params
    @request = request
    @response = response

    @["#{action}_action"]()

  # Sets a response header
  #
  # @param [String] field
  # @param [String] value
  header: (field, value) ->
    @response.header field, value

  # Sets the Content-Type header
  #
  # @param [String] value
  content_type: (value) ->
    @header 'Content-Type', value

  # Will write content and send the response
  #
  # @param [Object, String] result The value you want to send.
  respond: (result) ->
    # End early if we're dealing with a binary Buffer object.
    if result instanceof Buffer
      return @response.end result

    #TODO We could make these checks a little smarter.

    if result instanceof BlueprintItemCollection
      @content_type 'application/json'
      return @response.end result.json()

    if result instanceof BlueprintItem
      @content_type 'application/json'
      return @response.end result.json()

    # Make sure we're always ending with a string.
    if result instanceof Object
      return @response.json result

    @response.end result

  # Will abort the request and set the status code
  #
  # @param [Integer] code http status code
  abort: (code, message=null) ->
    @response.status(code)
    @response.end()
