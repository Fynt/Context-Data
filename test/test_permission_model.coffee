assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'Permission Model', ->
  permission_model = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      permission_model = Models(database.connection()).Permission
      done()

  it 'can save a permission', (done) ->
    permission_model.forge
      group_id: 1
      blueprint_id: 1
      action: 'save'
    .save().then (permission) ->
      assert permission.id?
      done()

  it 'can find a permission', (done) ->
    permission_model.forge
      group_id: 1
      blueprint_id: 1
      action: 'save'
    .fetch().then (permission) ->
      assert permission.id?
      done()
