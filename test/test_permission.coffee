assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'Permission', ->
  permission_model = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      permission_model = Models(database.connection()).Permission
      done()

  it 'can save a permission', (done) ->
    permission = permission_model.forge
      group_id: 1
      action: 'save'

    permission.save().then ->
      assert permission.id?
      done()

  it 'can find a permission', (done) ->
    permission = permission_model.forge
      group_id: 1
      action: 'save'

    permission.fetch().then ->
      assert permission.id?
      done()
