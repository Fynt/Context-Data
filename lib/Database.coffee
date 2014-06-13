Knex = require 'knex'


module.exports = class Database

  # @param config [Object]
  constructor: (@config, @knex=null) ->

  connection: ->
    if not @knex?
      @knex = Knex.initialize @config

    @knex

  # @param name [String] The name of the table.
  # @return [Object] An instance of the Knex query builder.
  table: (table_name) ->
    @connection() table_name

  # @param table_name [String] The name of the table.
  # @param data [Object] The row data.
  insert: (table_name, data, callback) ->
    @table table_name
    .insert data
    .exec callback
