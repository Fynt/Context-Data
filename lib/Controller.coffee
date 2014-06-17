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
    @request = request
    @response = response

    @params = request.params
    @query = request.query
    @form = request.body
    @session = request.session
    @redirect = response.redirect

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

    # Make sure we're always ending with a string.
    if result instanceof Object
      return @response.json result

    @response.end result

  # Will abort the request and set the status code
  #
  # @param code [Integer] HTTP status code
  # @param message [String] Status messsage
  abort: (code, message=null) ->
    #TODO Maybe thing of some better way to deal with the message.
    console.log message if message

    @response.status(code)
    @response.end()
