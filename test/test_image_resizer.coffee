assert = require 'assert'
global.config = require('konfig')()

gm = require 'gm'
Resizer = require '../server/lib/Image/Resizer'
LocalStorage = require '../server/lib/Storage/Local'


describe 'Image Resizer', ->
  storage = null

  before (done) ->
    file = new FileModel
      source: 'test.txt'
      extension: 'txt'

    storage = new LocalStorage file
    done()
