assert = require 'assert'
global.config = require('konfig')()

Database = require '../lib/Database'
Models = require '../lib/Models'


describe 'File', ->

  file_model = null
  file_data =
    source: 'test.txt'
    extension: 'txt'
    size: 123

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      file_model = Models(database.connection()).File
      done()

  it 'can save a file', (done) ->
    file_model.forge file_data
    .save().then (file) ->
      assert file.id?
      done()

  it 'can find a file', (done) ->
    # Create a file
    file_model.forge file_data
    .save().then (file) ->
      # Find a file.
      file_model.forge
        id: file.id
      .fetch().then (file) ->
        assert file.id?
        done()
