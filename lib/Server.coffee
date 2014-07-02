express = require 'express'

# Include express middleware
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
session = require 'express-session'


# The Server class
module.exports = class Server

  # @property [Object]
  controllers: {}

  # @param config [Object] The Application config
  # @param blueprint_manager [BlueprintManager]
  constructor: (@config, @db) ->
    @controllers_directory = @config.server.controller_directory

    @core = express()
    @initialize()

  # Gets an instance of the database
  #
  # @return [Database]
  database: ->
    @db

  # Initialize the application by registering routes, etc.
  #
  # @private
  initialize: ->
    @core.use bodyParser()
    @core.use cookieParser()
    @core.use session
      secret: @config.server.secret_key

    if @config.server.cors_enabled?
      # Enable CORS by setting the appropriate headers.
      @core.all '*', (request, response, next) =>
        response.header "Access-Control-Allow-Origin",
          @config.server.cors_origin
        response.header "Access-Control-Allow-Headers", "X-Requested-With"
        next()

    if @config.routes?
      @register_routes @config.routes

  # Allows us to lazy load controllers, and not instantiate the same controller
  #   multiple times.
  #
  # @param controller_name [String]
  # @return [String]
  get_controller: (controller_name) ->
    if not @controllers[controller_name]?
      controller_path = "#{@controllers_directory}/#{controller_name}"
      controller_class = require controller_path
      controller = new controller_class @

      @controllers[controller_name] = controller
    else
      controller = @controllers[controller_name]

    controller

  # Parses routes from the config and registers them
  #
  # @param routes_config [Object]
  register_routes: (routes_config) ->
    for method_path, controller_action of routes_config
      method_path = method_path.split " "
      controller_action = controller_action.split "#"

      # Split up arguments
      method = method_path[0]
      path = method_path[1]
      controller_name = controller_action[0]
      action = controller_action[1]

      controller = @get_controller controller_name

      @register_route method, path, controller, action

  # Registers an individual route. Should be called by register_routes.
  #
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
