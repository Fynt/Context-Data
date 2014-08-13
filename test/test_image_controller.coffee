request = require 'supertest'
assert = require 'assert'

config = require('konfig')()
Application = require '../server/Application'
ImageModel = require '../server/models/ImageModel'


describe 'Image Controller', ->
  req = null

  before (done) ->
    app = new Application config
    req = request app.core

    image = new ImageModel
      file_id: 1
      scale: 1
      width: 800
      height: 600
      crop_origin_x: 0
      crop_origin_y: 0
      source: 'test.jpg'
      extension: 'jpg'
    image.save done

  it 'can show an existing image', ->
    req.get('/image/800/600/1.jpg').expect(200).end (error, res) ->
      assert.equal error, null
