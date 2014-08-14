assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'

FileStorageMock = require '../lib/File/Storage/Mock'
FileStorageLocal = require '../lib/File/Storage/Local'

storage_classes =
  'FileStorageMock': FileStorageMock
  'FileStorageLocal': FileStorageLocal

for name, storage_class of storage_classes

  describe name, ->

    storage = null

    before (done) ->
      database = new Database config.db

      database.connection().migrate.latest config.migrate
      .then ->
        # Create a file.
        file_model = Models(database.connection()).File
        file = file_model.forge
          source: 'test.txt'
          extension: 'txt'

        # Instantiate the storage.
        storage = new storage_class file
        done()

    it 'has a mimetype method', ->
      assert.equal storage.mimetype(), 'text/plain'

    it 'has a filename method', ->
      assert.equal storage.filename(), 'test.txt'
