assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'Image', ->
  image_model = null
  image = null

  before (done) ->
    database = new Database config.db
    database.connection().migrate.latest config.migrate
    .then ->
      image_model = Models(database.connection()).Image
      image_model.forge
        source: 'test.txt'
        extension: 'txt'
        width: 100
        height: 100
      .save().then (new_image) ->
        image = new_image
        done()

  describe 'Model', ->

    it 'can find by id', ->
      image_model.forge
        id: 1
      .fetch().then (image) ->
        assert.equal 1, image.id

  describe 'Object', ->

    it 'should have an id', ->
      assert image.id?

    it 'should have a source', ->
      assert image.get('source')?

    it 'should have an extension', ->
      assert image.get('extension')?
