assert = require 'assert'
global.config = require('konfig')()

FileModel = require '../server/models/FileModel'
Storage = require '../server/lib/Storage'


describe 'File', ->
  file = null

  beforeEach (done) ->
    file = new FileModel
      source: 'test.txt'
      extension: 'txt'
      size: 123
    file.save done

  describe 'Model', ->

    it 'can find by id', ->
      FileModel.findById 1, (err, file) ->
        assert.equal 1, file.id

  describe 'Object', ->

    it 'should be a Model', ->
      assert.equal file instanceof FileModel, true

    it 'should have an id', ->
      assert.equal file.id?, true

    it 'should have a source', ->
      assert.equal file.source?, true

    it 'should have an extension', ->
      assert.equal file.extension?, true

    it 'should have a created date', ->
      assert.equal file.created?, true

    it 'should be valid', ->
      file.isValid (valid) ->
        assert.equal valid, true

    it 'has storage', ->
      storage = file.storage()
      assert.equal storage instanceof Storage, true
