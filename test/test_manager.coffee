assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintManager = require '../lib/Blueprint/Manager'


describe 'BlueprintManager', ->
  manager = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      done()

  it 'should have a database method', ->
    assert manager.database?

  it 'should be able to return a database instance', ->
    assert manager.database() instanceof Database

  it 'can load a Blueprint', ->
    post_blueprint = manager.get 'blog', 'Post'
    assert post_blueprint instanceof Blueprint

  it 'can get a blueprint id', (done) ->
    manager.get_id 'blog', 'Post', (error, blueprint_id) ->
      assert.equal blueprint_id, 1
      done()

  it 'will not generate an id twice', (done) ->
    manager.get_id 'blog', 'Comment', (error, first_id) ->
      manager.get_id 'blog', 'Comment', (error, second_id) ->
        assert.equal first_id, second_id
        done()

  it 'will generate unique ids', (done) ->
    manager.get_id 'blog', 'Comment', (error, first_id) ->
      manager.get_id 'blog', 'Post', (error, second_id) ->
        assert.notEqual first_id, second_id
        done()
