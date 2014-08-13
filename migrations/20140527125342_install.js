exports.up = function(knex, Promise) {
  knex.schema.createTable('blueprint', function(table) {
    table.increments('id').unsigned();
    table.string('extension', 30).notNullable();
    table.string('name', 40).notNullable();
    table.string('slug', 40).notNullable();
    table.timestamps();
    table.unique(['extension', 'slug']);
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
    table.integer('data_id').unsigned().notNullable().references('data.id');
    table.integer('blueprint_id').unsigned().notNullable()
    .references('blueprint.id');
    table.string('key', 25).notNullable();
    table.string('value', 255).notNullable();
    table.index(['blueprint_id', 'key', 'value']);
    table.unique(['data_id', 'key']);
  }).then();

  knex.schema.createTable('user', function(table) {
    table.increments('id').unsigned();
    table.integer('group_id').unsigned().notNullable().references('group.id');
    table.string('email', 254).notNullable().unique();
    table.string('name', 40).notNullable();
    table.string('password', 60).notNullable();
    table.dateTime('last_login');
    table.timestamps();
    table.index(['email', 'password']);
  }).then();

  knex.schema.createTable('group', function(table) {
    table.increments('id').unsigned();
    table.string('label', 40).notNullable().unique();
    table.timestamps();
  }).then(function() {
    // Create the default group.
    knex.table('group')
      .insert({
        label: 'Admin'
      })
      .exec();
  });

  knex.schema.createTable('permission', function(table) {
    table.increments('id').unsigned();
    table.integer('group_id').unsigned().notNullable().index()
    .references('group.id');
    table.string('type', 40).notNullable();
    table.string('resource', 40).notNullable();
    table.string('action', 40).notNullable();
    table.boolean('is_allowed').notNullable().defaultTo(true);
    table.timestamps();
    table.unique(['group_id', 'type', 'resource', 'action']);
  }).then();

  knex.schema.createTable('file', function(table) {
    table.increments('id').unsigned();
    table.string('source', 100).notNullable();
    table.string('extension', 4).notNullable().index();
    table.integer('size').unsigned();
    table.timestamps();
    table.unique(['source', 'extension']);
  }).then();

  knex.schema.createTable('image', function(table) {
    table.increments('id').unsigned();
    table.float('scale');
    table.integer('width').unsigned().notNullable();
    table.integer('height').unsigned().notNullable();
    table.integer('crop_origin_x').unsigned();
    table.integer('crop_origin_y').unsigned();
    table.string('source', 100).notNullable();
    table.string('extension', 4).notNullable().index();
    table.timestamps();
    table.unique(['scale', 'width', 'height', 'crop_origin_x', 'crop_origin_y',
      'source', 'extension']);
  }).then();
};

exports.down = function(knex, Promise) {
  knex.schema.dropTableIfExists('blueprint').then();
  knex.schema.dropTableIfExists('data').then();
  knex.schema.dropTableIfExists('history').then();
  knex.schema.dropTableIfExists('relationship').then();
  knex.schema.dropTableIfExists('index').then();
  knex.schema.dropTableIfExists('user').then();
  knex.schema.dropTableIfExists('group').then();
  knex.schema.dropTableIfExists('permission').then();
  knex.schema.dropTableIfExists('file').then();
  knex.schema.dropTableIfExists('image').then();
};
