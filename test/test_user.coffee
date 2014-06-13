assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Model = require '../lib/Model'
User = require '../lib/User'


describe 'User', ->
  user = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      user = new User
      done()

  it 'is an instance of Model', ->
    assert user instanceof Model
