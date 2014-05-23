config = require('konfig')()
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'

database = new Database config.db
manager = new BlueprintManager database

blueprint = manager.get 'blog', 'Post'
item = blueprint.create()

item.set 'hello', 'world!'
item.save ->
  console.log "LOL"
