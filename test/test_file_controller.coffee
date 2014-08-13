request = require 'supertest'
assert = require 'assert'

global.config = require('konfig')()
Application = require '../server/Application'
FileModel = require '../server/models/FileModel'


describe 'File Controller', ->
  req = null

  before (done) ->
    app = new Application global.config
    req = request app.core

    file = new FileModel
      source: 'test.txt'
      extension: 'txt'
    file.save done

  it 'can get a file', ->
    req.get('/file/1').expect(200).end (error, res) ->
      assert.equal error, null

  it 'returns a 404 for an invalid file', ->
    req.get('/file/0').expect(404).end (error, res) ->
      assert.equal error, null

  it 'can show a file', ->
    req.get '/file/show/1'
    .expect 'Content-Type', /text/
    .expect 200
    .end (error, res) ->
      throw error if error
      assert.equal error, null
