assert = require 'assert'

BlueprintPlugins = require '../lib/Blueprint/Plugins'
BlueprintPluginTest = require '../lib/Blueprint/Plugin/Test'

describe 'Blueprint Plugins', ->

  plugins = null
  test_plugin = null

  before (done) ->
    plugins = new BlueprintPlugins
    test_plugin = new BlueprintPluginTest

    plugins.register_plugin test_plugin

    done()

  it 'can call a plugin', (done) ->
    plugins.event 'test', null, null
    .then ->
      assert.equal test_plugin.called_test, true
      done()

  it 'can call a plugin where promises are returned', (done) ->
    plugins.event 'test_promise', null, null
    .then ->
      assert.equal test_plugin.called_test, true
      done()

  it 'can get rejected from a plugin', (done) ->
    plugins.event 'test_error', null, null
    .catch ->
      assert true
      done()
