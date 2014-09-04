assert = require 'assert'
config = require('konfig')()

Models = require '../lib/Models'
Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'
BlueprintRelationship = require '../lib/Blueprint/Relationship'


describe 'Model Relationship', ->
  manager = null
  image_model = null
  product_blueprint = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      image_model = Models(database.connection()).Image
      product_blueprint = manager.get 'store', 'Product'

      done()

  describe 'HasManyModel', ->
    relationship = null

    before (done) ->
      product = product_blueprint.create()
      relationship = product.photos
      console.log relationship
      done()

    it 'is an instance of BlueprintRelationship', ->
      assert relationship instanceof BlueprintRelationship

    # it 'can add an item through a relationship', (done) ->
    #   assert false
    #   done()
    #
    # it 'can load an item through a relationship', (done) ->
    #   assert false
    #   done()

  describe 'HasOneModel', ->
    relationship = null

    before (done) ->
      product = product_blueprint.create()
      relationship = product.preview
      console.log relationship
      done()

    it 'is an instance of BlueprintRelationship', ->
      assert relationship instanceof BlueprintRelationship

    # it 'can add an item through a relationship', (done) ->
    #   assert false
    #   done()
    #
    # it 'can load an item through a relationship', (done) ->
    #   assert false
    #   done()
