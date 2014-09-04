assert = require 'assert'
global.config = require('konfig')()

Models = require '../lib/Models'
Database = require '../lib/Database'


describe 'File', ->

  file_model = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      file_model = Models(database.connection()).File
      done()

  it 'can save a file', (done) ->
    file_model.forge
      source: 'test.txt'
      extension: 'txt'
      size: 123
    .save().then (file) ->
      assert file.id?
      done()

  it 'can find a file', (done) ->
    # Create a file
    file_model.forge
      source: 'test2.txt'
      extension: 'txt'
      size: 321
    .save().then (file) ->
      # Find a file.
      file_model.forge
        id: file.id
      .fetch().then (file) ->
        assert file.id?
        done()
