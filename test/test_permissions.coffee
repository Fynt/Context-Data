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
      permissions = new Permissions database

      # Create a user
      new models.User
        email: 'ham@fynt.ca'
        password: 'gr33n3gg5'
      .save().then (result) ->
        user = result

        # Create a permission
        new models.Permission
          group_id: 1
          action: 'test'
        .save().then ->
          done()

  it 'can get a user id', ->
    assert permissions.get_user_id(user) == user.id

  it 'can get a group', (done) ->
    permissions.get_group user
    .then (group) ->
      assert group.id?
      done()

  it 'can check if an action is allowed', (done) ->
    permissions.is_allowed user, 'test'
    .then (allowed) ->
      assert allowed
      done()
