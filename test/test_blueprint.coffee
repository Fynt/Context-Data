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
    item = blueprint.create()
    item.populate title: 'Hello', body: 'World!'

    blueprint.save item, (error, item) ->
      assert item.id?
      done()

  it 'can find an item by id', (done) ->
    item = blueprint.create()
    blueprint.save item, (error, item) ->
      blueprint.find_by_id item.id, (error, found_item) ->
        assert.equal item.id, found_item.id
        done()

  it 'can destroy an item', (done) ->
    blueprint.save blueprint.create(), (error, item) ->
      blueprint.destroy item, (error, item) ->
        blueprint.find_by_id item.id, (error, found_item) ->
          assert.equal found_item, null
          done()

  it 'can get a blueprint', ->
    other_blueprint = blueprint.get_blueprint 'Comment'
    assert other_blueprint instanceof Blueprint

  it 'can get a blueprint from another extension', ->
    other_blueprint = blueprint.get_blueprint 'Product', 'store'
    assert other_blueprint instanceof Blueprint
