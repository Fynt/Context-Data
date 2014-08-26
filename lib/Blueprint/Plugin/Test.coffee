Promise = require 'bluebird'
BlueprintPlugin = require '../Plugin'


# This plugin exists for testing plugins. Probably don't use this, mmkay?
module.exports = class BlueprintPluginTest extends BlueprintPlugin

  called_test: false

  test: ->
    @called_test = true

  test_promise: ->
    @called_test = false
    new Promise (resolve, reject) =>
      @called_test = true
      resolve()

  test_error: ->
    new Promise (resolve, reject) ->
      reject new Error "Reject"
