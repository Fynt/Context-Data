assert = require 'assert'
config = require('konfig')()

ImageResizer = require '../lib/Image/Resizer'


describe 'ImageResizer', ->
  image_resizer = null

  before (done) ->
    image_resizer = new ImageResizer
    done()
