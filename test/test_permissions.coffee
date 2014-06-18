assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'
Permissions = require '../lib/Permissions'


describe 'Permissions', ->

  user = null
  permissions = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      models = Models database.connection()

      user = new models.User
        email: 'ham@fynt.ca'
        password: 'gr33n3gg5'
      .save().then (result) ->
        user = result
        permissions = new Permissions user, database
        done()

  it 'can get a user id', ->
    assert permissions.get_user_id() == user.id

  it 'can get a group', (done) ->
    permissions.get_group()
    .then (group) ->
      assert group.id?
      done()
