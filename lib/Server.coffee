express = require 'express'


# The Server class
module.exports = class Server

  # @param [Object] config The Application config
  constructor: (@config) ->
    @core = express()
    @initialize()

  # Initialize the application by registering routes, etc.
  #
  # @private
  initialize: ->

  # @param [String] method
  # @param [String] path
  # @param [Controller] controller
  # @param [String] action
  register_route: (method, path, controller, action) ->
    route = @core.route path
    handle = (request, response) ->
      controller.call_action action, request, response

    switch method
      when '*' then route.all handle
      when 'GET' then route.get handle
      when 'POST' then route.post handle
      when 'PUT' then route.put handle
      when 'DELETE' then route.delete handle

  # Starts the event loop to listen for requests.
  start: ->
    @core.listen @config.server.port
