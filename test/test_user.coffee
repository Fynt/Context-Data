assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Model = require '../lib/Model'
ModelItem = require '../lib/Model/Item'
User = require '../lib/User'


describe 'User', ->
  user_model = null
  email_address = 'spam@domain.com'

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      user_model = new User database
      done()

  it 'is an instance of Model', ->
    assert user_model instanceof Model

  it 'can create a user', ->
    user = user_model.create()
    assert user instanceof ModelItem

  it 'can save a user', (done) ->
    user = user_model.create email: email_address
    user.save (error, user) ->
      done()

  it 'can find a user by email', (done) ->
    user_model.find_by_email email_address, (error, user) ->
      assert user instanceof ModelItem
      #assert user.get 'email' == email_address
      done()
