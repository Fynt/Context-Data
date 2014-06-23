Server = require './lib/Server'
Database = require './lib/Database'


module.exports = (config) ->
  database = new Database config.db
  new Server config, database
