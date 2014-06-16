config = require('konfig')()
Server = require './lib/Server'
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'


database = new Database config.db
blueprint_manager = new BlueprintManager database

# Just adding this temporarily
database.connection().migrate.latest config.migrate
.then ->
  console.log "Migrated database..."

server = new Server config, blueprint_manager

module.exports = server
