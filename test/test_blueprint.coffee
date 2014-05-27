assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'


describe 'Blueprint', ->
  blueprint = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      blueprint = manager.get 'blog', 'Post'

      done()

  it 'should have a database method', ->
    assert blueprint.database?

  it 'should be able to return a database instance', ->
    assert blueprint.database() instanceof Database

  it 'can create an item', ->
    assert blueprint.create() instanceof BlueprintItem
