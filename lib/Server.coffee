path = require 'path'
express = require 'express'

# Include express middleware
multer  = require 'multer'
bodyParser = require 'body-parser'
session = require 'express-session'
cookieParser = require 'cookie-parser'


# The Server class
module.exports = class Server

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

    # Add middleware for handling multipart form data.
    root_path = path.dirname require.main.filename
    @core.use multer dest: "#{root_path}/data/files"

    if @config.server.cors_enabled?
      # Enable CORS by setting the appropriate headers.
      @core.all '*', (request, response, next) =>
        response.header "Access-Control-Allow-Origin",
          @config.server.cors_origin
        response.header "Access-Control-Allow-Credentials", true
        response.header "Access-Control-Allow-Headers",
          "Origin, Accept, X-Requested-With, Content-Type, Content-Range, " +
          "Content-Disposition, Content-Description"
        response.header "Access-Control-Allow-Methods",
          "GET, POST, PUT, DELETE, OPTIONS"
        next()

    if @config.routes?
      @register_routes @config.routes

  # Controller factory.
  #
  # @param controller_name [String]
  # @return [String]
  get_controller: (controller_name) ->
    controller_path = "#{@controllers_directory}/#{controller_name}"
    controller_class = require controller_path
    new controller_class @

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

      @register_route method, path, controller_name, action

  # Registers an individual route. Should be called by register_routes.
  #
  # Can also run in chaos_mode as defined by the config, which can be useful for
  # testing the admin, and simulating network.
  #
  # @param [String] method
  # @param [String] path
  # @param [String] controller_name
  # @param [String] action
  register_route: (method, path, controller_name, action) ->
    route = @core.route path
    handle = (request, response) =>
      controller = @get_controller controller_name

      # Check if we should be using chaos mode.
      if @config.server.chaos_mode? and @config.server.chaos_mode
        # Get settings.
        max_time = @config.server.chaos_mode_max_time or 500
        timout_threshold = @config.server.chaos_mode_timout_threshold or 0.95

        # Get a random time.
        timer = Math.ceil(Math.random() * max_time)

        if timer > (max_time * timout_threshold)
          # Simulate a timeout
          response.status(420)
          response.end()
        else
          # Call the action with a delay to simulate network latency, etc.
          setTimeout ->
            controller.call_action action, request, response
          , timer
      else
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
