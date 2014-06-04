exports.up = function(knex, Promise) {
  knex.schema.createTable('blueprint', function(table) {
    table.increments('id').unsigned();
    table.string('extension', 30).notNullable();
    table.string('name', 40).notNullable();
    table.unique(['extension', 'name']);
  }).then();

  knex.schema.createTable('data', function(table) {
    table.increments('id').unsigned();
    table.integer('blueprint_id').unsigned().notNullable().index();
    table.integer('author').unsigned().notNullable();
    table.json('data').notNullable();
    table.timestamps();
    table.boolean('published');
  }).then();

  knex.schema.createTable('snapshot', function(table) {
    table.increments('id').unsigned();
    table.integer('data_id').unsigned().notNullable().index();
    table.integer('blueprint_id').unsigned().notNullable();
    table.json('data').notNullable();
  }).then();

  knex.schema.createTable('history', function(table) {
    table.increments('id').unsigned();
    table.integer('author').notNullable().index();
    table.string('action', 30).notNullable().index();
    table.integer('data_id').unsigned();
    table.integer('snapshot_id').unsigned();
    table.dateTime('created_at').notNullable().index();
  }).then();

  knex.schema.createTable('relationship', function(table) {
    table.increments('id').unsigned();
    table.integer('parent_blueprint_id').unsigned().notNullable();
    table.integer('parent_data_id').unsigned().notNullable();
    table.integer('child_blueprint_id').unsigned().notNullable();
    table.integer('child_data_id').unsigned().notNullable();
    table.index(['parent_data_id', 'child_blueprint_id']);
    table.index(['child_data_id', 'parent_blueprint_id']);
    table.unique(['parent_data_id', 'child_data_id']);
  }).then();

  knex.schema.createTable('index', function(table) {
    table.increments('id').unsigned();
    table.integer('data_id').unsigned().notNullable();
    table.integer('blueprint_id').unsigned().notNullable();
    table.string('key', 25).notNullable();
    table.string('value', 255).notNullable();
    table.index(['blueprint_id', 'key', 'value']);
    table.unique(['data_id', 'key']);
  }).then();
};

exports.down = function(knex, Promise) {
  knex.schema.dropTableIfExists('blueprint').then();
  knex.schema.dropTableIfExists('data').then();
  knex.schema.dropTableIfExists('history').then();
  knex.schema.dropTableIfExists('relationship').then();
  knex.schema.dropTableIfExists('index').then();
};
