assert = require 'assert'
config = require('konfig')()
Database = require '../lib/Database'


describe 'Database', ->
  database = null

  before (done) ->
    database = new Database config.db

    database.connection().migrate.latest config.migrate
    .then ->
      done()

  it 'should have a blueprint table', ->
    database.connection().schema.hasTable 'blueprint'
    .then (exists) ->
      assert exists

  it 'should have a data table', ->
    database.connection().schema.hasTable 'data'
    .then (exists) ->
      assert exists

  it 'should have a history table', ->
    database.connection().schema.hasTable 'history'
    .then (exists) ->
      assert exists

  it 'should have a relationship table', ->
    database.connection().schema.hasTable 'relationship'
    .then (exists) ->
      assert exists

  it 'should have a index table', ->
    database.connection().schema.hasTable 'index'
    .then (exists) ->
      assert exists
