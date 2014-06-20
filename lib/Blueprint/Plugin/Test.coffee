Promise = require 'bluebird'
BlueprintPlugin = require '../Plugin'


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
