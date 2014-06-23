assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'User Model', ->
  
  user_model = null

  email = 'spam@domain.com'
  password = 'bacon'

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      user_model = Models(database.connection()).User
      done()

  it 'can save a user', (done) ->
    user_model.forge
      email: email
      password: password
    .save().then (user) ->
      assert user.id?
      done()

  it 'can find a user', (done) ->
    user_model.forge
      email: email
    .fetch
      withRelated: 'group'
    .then (user) ->
      assert user.id?
      done()

  it 'can hash a password', ->
    password = 'bacon'
    user = user_model.forge
      email: email

    user.set_password password
    assert user.check_password password
