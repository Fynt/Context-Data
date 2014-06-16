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

  it 'can do a thing', (done) ->
    user_model.login email_address, 'bacon'
    .then (user) ->
      console.log user
      done()
    .catch (error) ->
      console.log error
      done()
