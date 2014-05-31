assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'
BlueprintRelationship = require '../lib/Blueprint/Relationship'


describe 'Item', ->
  item = null
  item_title = 'Test'
  item_body = 'LOL'

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      blueprint = manager.get 'blog', 'Post'

      item = new BlueprintItem blueprint
      item.populate
        title: item_title
        body: item_body

      done()

  it 'can get an id', (done) ->
    item.get_id (error, id) ->
      assert id?
      done()

  it 'can publish itself', ->
    item.publish()
    assert.equal item.published, true

  it 'can unpublish iteself', ->
    item.unpublish()
    assert.equal item.published, false

  describe 'default properties', ->

    it 'has an id', ->
      assert item.id != undefined

    it 'has data', ->
      assert item.data?

    it 'has published', ->
      assert item.published?

  describe 'dynamic properties', ->

    it 'has dynamic getter', ->
      assert.equal item.title, item_title
      assert.equal item.body, item_body

    it 'has dynamic setter', ->
      body = 'ROFL'
      item.body = body

      assert.equal item.body, body

    it 'has a relationship', ->
      assert item.comments?
      assert item.comments instanceof BlueprintRelationship
