config = require('konfig')()
Server = require './lib/Server'

server = new Server config

#TODO Register controllers, etc.

server.start()
