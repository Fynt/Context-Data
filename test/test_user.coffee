assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'User', ->
  user_model = null
  email_address = 'spam@domain.com'

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      user_model = Models(database.connection()).User
      done()
