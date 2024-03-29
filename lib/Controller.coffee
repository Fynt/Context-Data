# The base Controller class
#
# @abstract
module.exports = class Controller

  # @param server [Server] The Server instance
  constructor: (@server) ->
    @initialize()

  # Provides a hook to do controller specific initialization. This is called
  # when the controller instance is created, which may only happen once in the
  # application lifecycle. Use the before_action and after_action methods to
  # manage sessions, and other things that need to be tied to the actual request
  # handling.
  #
  # @abstract
  initialize: ->

  # Called by the application when dispatching a request.
  #
  # @param action [String] The action you want called.
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

    @before_action action
    @["#{action}_action"]()
    @after_action action

  # Provides a hook to do set-up before the action is called.
  #
  # @abstract
  # @private
  # @param action [String] The name of the action.
  # @return [Null, Boolean] Returning false will prevent the action from getting
  #   called.
  before_action: (action) ->

  # Provides a hook to do tear-down after the action is called.
  #
  # @abstract
  # @private
  # @param action [String]  The name of the action.
  after_action: (action) ->

  # Sets a response header
  #
  # @param field [String]
  # @param value [String]
  header: (field, value) ->
    @response.header field, value

  # Sets the Content-Type header
  #
  # @param value [String]
  content_type: (value) ->
    @header 'Content-Type', value

  # Will write content and send the response
  #
  # @param result [Object, String] The value you want to send.
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
    if message
      console.error message

    @response.status(code)
    @response.end()
