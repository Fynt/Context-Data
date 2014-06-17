config = require('konfig')()
Server = require './lib/Server'
Database = require './lib/Database'

database = new Database config.db

server = new Server config, database
server.start()
