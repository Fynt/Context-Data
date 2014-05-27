assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'


describe 'Item', ->
  blueprint = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      blueprint = manager.get 'blog', 'Post'

      done()

  describe 'properties', ->

    item = null

    before (done) ->
      item = new BlueprintItem blueprint
      done()

    it 'has an id', ->
      # We just want to see this property exists, and .id? will fail because the
      # default is null.
      assert.equal item.id, null

    it 'has data', ->
      assert item.data?

    it 'has published', ->
      assert item.published?
