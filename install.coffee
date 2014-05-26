config = require('konfig')()
Knex = require 'knex'

knex = Knex.initialize config.db

knex.schema.dropTableIfExists 'blueprint'
knex.schema.createTable 'blueprint', (table) ->
  table.increments('id').unsigned()
  table.string('extension', 30).notNullable()
  table.string('name', 40).notNullable()
  table.unique(['extension', 'name'])
.then ->
  console.log "Type table created..."

knex.schema.dropTableIfExists 'data'
knex.schema.createTable 'data', (table) ->
  table.increments('id').unsigned()
  table.integer('blueprint_id').unsigned().notNullable().index()
  table.integer('author').unsigned().notNullable()
  table.json('data').notNullable()
  table.timestamps()
  table.boolean 'published'
.then ->
  console.log "Data table created..."

knex.schema.dropTableIfExists 'history'
knex.schema.createTable 'history', (table) ->
  table.increments('id').unsigned()
.then ->
  console.log "History table created..."

knex.schema.dropTableIfExists 'relationship'
knex.schema.createTable 'relationship', (table) ->
  table.increments('id').unsigned()
  table.integer('parent_blueprint_id').unsigned().notNullable()
  table.integer('parent_data_id').unsigned().notNullable()
  table.integer('child_blueprint_id').unsigned().notNullable()
  table.integer('child_data_id').unsigned().notNullable()

  table.index(['parent_data_id', 'child_blueprint_id'])
  table.index(['child_data_id', 'parent_blueprint_id'])
  table.unique(['parent_data_id', 'child_data_id'])
.then ->
  console.log "Relationship table created..."

knex.schema.dropTableIfExists 'index'
knex.schema.createTable 'index', (table) ->
  table.increments('id').unsigned()
  table.integer('data_id').unsigned().notNullable()
  table.integer('blueprint_id').unsigned().notNullable()
  table.string('key', 25).notNullable()
  table.string('value', 255).notNullable()
.then ->
  console.log "Index table created..."
