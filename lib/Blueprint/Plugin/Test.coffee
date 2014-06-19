Promise = require 'bluebird'
BlueprintPlugin = require '../Plugin'


module.exports = class BlueprintPluginTest extends BlueprintPlugin

  called_test: false

  # @param blueprint [Blueprint]
  # @return [Promise]
  test: (blueprint) ->
    p = Promise.pending()

    call_test = =>
      @called_test = true
    call_test()

    p.promise
