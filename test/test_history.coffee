assert = require 'assert'
config = require('konfig')()
Database = require '../lib/Database'
BlueprintHistoryManager = require '../lib/Blueprint/HistoryManager'


describe 'History', ->
  history = null

  before (done) ->
    database = new Database config.db
    history = new BlueprintHistoryManager database

    database.connection().migrate.latest config.migrate
    .then ->
      done()

  it 'has an instance of the database', ->
    assert history.database() instanceof Database

  it 'can register an action', (done) ->
    history.register_action 1, 'Test', (error, ids) ->
      assert error == null
      assert ids.length == 1
      done()
