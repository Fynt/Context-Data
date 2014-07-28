assert = require 'assert'
config = require('konfig')()

Models = require '../lib/Models'
Database = require '../lib/Database'
Permissions = require '../lib/Permissions'
BlueprintManager = require '../lib/Blueprint/Manager'


describe 'Permissions', ->

  user = null
  blueprint = null
  permissions = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      models = Models database.connection()
      permissions = new Permissions database

      # Get a blueprint
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"
      blueprint = manager.get 'blog', 'Post'

      # Create a user
      new models.User
        email: 'ham@fynt.ca'
        name: 'waffle'
        password: 'gr33n3gg5'
      .save().then (result) ->
        user = result

        # Create a permission
        new models.Permission
          group_id: 1
          type: 'blueprint'
          resource: blueprint.get_permission_resource()
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
    permissions.is_allowed user, blueprint, 'test'
    .then (allowed) ->
      assert allowed
      done()
