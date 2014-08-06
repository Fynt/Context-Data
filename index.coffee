Server = require './lib/Server'
Models = require './lib/Models'
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'


exports.database = (config) ->
  new Database config.db

exports.blueprint_manager = (config) ->
  database = new Database config.db
  new BlueprintManager database

exports.models = (config) ->
  database = new Database config.db
  Models(database.connection())

exports.server = (config) ->
  database = new Database config.db
  new Server config, database
