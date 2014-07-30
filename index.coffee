Server = require './lib/Server'
Models = require './lib/Models'
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'


exports.database = database = (config) ->
  new Database config.db

exports.blueprint_manager = (config) ->
  database = database(config)
  new BlueprintManager database

exports.models = (config) ->
  database = database(config)
  Models(database.connection())

exports.server = (config) ->
  database = database(config)
  new Server config, database
