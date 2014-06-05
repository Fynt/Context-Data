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

  # Starts the event loop to listen for requests.
  start: ->
    @core.listen @config.server.port
