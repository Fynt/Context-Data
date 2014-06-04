assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'
BlueprintRelationship = require '../lib/Blueprint/Relationship'


describe 'Relationship', ->
  manager = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      done()

  describe 'HasMany', ->
    relationship = null
    post_blueprint = null
    comment_blueprint = null

    before (done) ->
      post_blueprint = manager.get 'blog', 'Post'
      comment_blueprint = manager.get 'blog', 'Comment'

      post = post_blueprint.create()
      relationship = post.comments

      done()

    it 'is an instance of BlueprintRelationship', ->
      assert relationship instanceof BlueprintRelationship

    it 'can add an item through a relationship', (done) ->
      comment = comment_blueprint.create()
      relationship.add comment, (error, post, comment) ->
        assert error is null
        done()

    it 'can load an item through a relationship', (done) ->
      comment = comment_blueprint.create()
      relationship.add comment, (error, post, comment) ->
        relationship.collection (collection) ->
          assert collection.length > 0
          done()
