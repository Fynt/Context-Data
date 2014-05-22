Knex = require 'knex'


module.exports = class Database

  constructor: (@config, @knex=null) ->

  connection: ->
    if not @knex?
      @knex = Knex.initialize @config

    @knex

  table: (name) ->
    connection name
