var config = require('konfig')();

module.exports = {
  database: config.db,
  directory: './migrations',
  tableName: 'migrations'
};
