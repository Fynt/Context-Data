assert = require 'assert'
global.config = require('konfig')()

FileModel = require '../server/models/FileModel'

MockStorage = require '../server/lib/Storage/Mock'
LocalStorage = require '../server/lib/Storage/Local'

storage_classes =
  'MockStorage': MockStorage
  'LocalStorage': LocalStorage

for name, StorageClass of storage_classes
  describe name, ->
    storage = null
    file = new FileModel
      source: 'test.txt'
      extension: 'txt'

    before (done) ->
      storage = new StorageClass file
      done()

    it 'has a mimetype method', ->
      assert.equal storage.mimetype(), 'text/plain'

    it 'has a filename method', ->
      assert.equal storage.filename(), 'test.txt'
