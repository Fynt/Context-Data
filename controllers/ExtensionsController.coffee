capitalize = require 'capitalize'
ApiController = require './ApiController'
BlueprintManager = require '../lib/Blueprint/Manager'


module.exports = class ExtensionsController extends ApiController

  initialize: ->
    @blueprint_manager = new BlueprintManager @server.database()

  find_all_action: ->
    @blueprint_manager.get_extensions()
    .then (results) =>
      id = 1
      extensions = []

      for extension in results
        extensions.push
          id: id++
          name: capitalize.words extension
          slug: extension

        @respond extensions, 'extensions'
    .catch (error) =>
      @abort 500
