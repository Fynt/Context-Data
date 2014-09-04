assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'
BlueprintRelationship = require '../lib/Blueprint/Relationship'


describe 'Model Relationship', ->
  manager = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      done()

  describe 'HasManyModel', ->
    it 'is an instance of BlueprintRelationship', ->
      assert relationship instanceof BlueprintRelationship

    it 'can add an item through a relationship', (done) ->
      assert false
      done()

    it 'can load an item through a relationship', (done) ->
      assert false
      done()

  describe 'BelongsToModel', ->
    it 'is an instance of BlueprintRelationship', ->
      assert relationship instanceof BlueprintRelationship

    it 'can add an item through a relationship', (done) ->
      assert false
      done()

    it 'can load an item through a relationship', (done) ->
      assert false
      done()

  describe 'HasOneModel', ->
    it 'is an instance of BlueprintRelationship', ->
      assert relationship instanceof BlueprintRelationship

    it 'can add an item through a relationship', (done) ->
      assert false
      done()

    it 'can load an item through a relationship', (done) ->
      assert false
      done()
