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
      permission_model = Models(database.connection()).Group
      done()
