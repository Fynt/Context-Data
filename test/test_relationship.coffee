assert = require 'assert'
config = require('konfig')()

Database = require '../lib/Database'
Blueprint = require '../lib/Blueprint'
BlueprintItem = require '../lib/Blueprint/Item'
BlueprintManager = require '../lib/Blueprint/Manager'
BlueprintRelationship = require '../lib/Blueprint/Relationship'


describe 'Relationship', ->
  blueprint = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      manager = new BlueprintManager database
      manager.extension_dir = "#{__dirname}/_data/extensions"

      blueprint = manager.get 'blog', 'Post'

      done()
