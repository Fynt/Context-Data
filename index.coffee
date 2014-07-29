Server = require './lib/Server'
Models = require './lib/Models'
Database = require './lib/Database'


exports.database = (config) ->
  new Database config.db

exports.models = (config) ->
  database = new Database config.db
  Models(database.connection())

exports.server = (config) ->
  database = new Database config.db
  new Server config, database
