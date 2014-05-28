Knex = require 'knex'


module.exports = class Database

  # @param config [Object]
  constructor: (@config, @knex=null) ->

  connection: ->
    if not @knex?
      @knex = Knex.initialize @config

    @knex

  # @param name [String] The name of the table
  table: (name) ->
    @connection() name
