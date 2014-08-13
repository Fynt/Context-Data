assert = require 'assert'
global.config = require('konfig')()

ImageModel = require '../server/models/ImageModel'
Storage = require '../server/lib/Storage'


describe 'Image', ->
  image = null

  beforeEach (done) ->
    image = new ImageModel
      source: 'test.txt'
      extension: 'txt'
    image.save done

  describe 'Model', ->

    it 'can find by id', ->
      ImageModel.findById 1, (err, image) ->
        assert.equal 1, image.id

  describe 'Object', ->

    it 'should be a Model', ->
      assert.equal image instanceof ImageModel, true

    it 'should have an id', ->
      assert.equal image.id?, true

    it 'should have a source', ->
      assert.equal image.source?, true

    it 'should have an extension', ->
      assert.equal image.extension?, true

    it 'should have a created date', ->
      assert.equal image.created?, true

    it 'should be valid', ->
      image.isValid (valid) ->
        assert.equal valid, true

    it 'has storage', ->
      storage = image.storage()
      assert.equal storage instanceof Storage, true
