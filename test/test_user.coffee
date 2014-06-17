assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'User', ->
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
    user = user_model.forge
      email: email
      password: password

    user.save().then ->
      assert user.id?
      done()

  it 'can find a user', (done) ->
    user = user_model.forge
      email: email

    user.fetch
      withRelated: 'group'
    .then ->
      assert user.id?
      done()

  it 'can hash a password', ->
    password = 'bacon'
    user = user_model.forge
      email: email

    user.set_password password
    assert user.check_password password
