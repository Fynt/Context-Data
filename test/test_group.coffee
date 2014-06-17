assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'Group', ->
  group_model = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      group_model = Models(database.connection()).Group
      done()
