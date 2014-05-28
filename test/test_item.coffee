assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'


describe 'Item', ->
  item = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      blueprint = manager.get 'blog', 'Post'

      item = new BlueprintItem blueprint
      item.data =
        title: 'Test'
        body: 'LOL'

      done()

  describe 'default properties', ->

    it 'has an id', ->
      # We just want to see this property exists, and .id? will fail because
      # the default is null.
      assert.equal item.id, null

    it 'has data', ->
      assert item.data?

    it 'has published', ->
      assert item.published?

  describe 'dynamic properties', ->

    it 'has dynamic getter', ->
      assert.equal item.title, 'Test'

    it 'has dynamic setter', ->
      body = 'ROFL'
      item.body = body

      assert.equal item.body, body
