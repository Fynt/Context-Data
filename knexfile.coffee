module.exports =

  development:
    client: 'sqlite3'
    connection:
      filename: ':memory:'
    migrations:
      tableName: 'knex_migrations'
