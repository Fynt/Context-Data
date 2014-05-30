config = require('konfig')()
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'

database = new Database config.db
manager = new BlueprintManager database
