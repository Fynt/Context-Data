assert = require 'assert'
config = require('konfig')()
supertest = require 'supertest'

Server = require '../lib/Server'
Database = require '../lib/Database'

describe 'Items API', ->

  request = null

  before (done) ->
    database = new Database config.db
    server = new Server config, database

    request = supertest server.core

    done()

  it 'Can find_all', ->
    request.get('/items').expect(200).end (error, res) ->
      console.log res
      assert.equal error, null
