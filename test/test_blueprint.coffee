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

  it 'can save an item', (done) ->
    # Create an item
    item = blueprint.create()
    item.populate title: 'Hello', body: 'World!'

    # Save the blueprint
    blueprint.save item, (error, item) ->
      assert item.id
      done()

  # it 'can find an item by id', (done) ->
  #   item = blueprint.create()
  #   item.data = hello: 'world'
  #   item.save (error, item) ->
  #     console.log item.id
  #     done()
      # blueprint.find_by_id item.id, (error, found_item) ->
      #   console.log item.id, found_item.id
      #   assert.equal item.id, found_item.id
      #   done()
