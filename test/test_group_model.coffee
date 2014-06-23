assert = require 'assert'

config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'Group Model', ->
  
  group_model = null
  group_label = 'Admin'

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      group_model = Models(database.connection()).Group
      done()

  it 'can save a group', (done) ->
    group_model.forge
      label: 'Eggs'
    .save().then (group) ->
      assert group.id?
      assert group.get('label') == 'Eggs'
      done()

  it 'can find a group', (done) ->
    group_model.forge
      label: group_label
    .fetch().then (group) ->
      assert group.id?
      assert group.get('label') == group_label
      done()
