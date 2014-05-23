config = require('konfig')()
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'

database = new Database config.db
manager = new BlueprintManager database

blueprint = manager.get 'blog', 'Post'

# Create an item
# item = blueprint.create()
#
# item.set 'hello', 'world!'
# item.save ->
#   console.log item.id, item.json()
#
#   item.set 'yo', 'dawg'
#   item.save ->
#     console.log item.id, item.json()

# Load an item by id

blueprint.find_by_id 24, (error, item) ->
  console.log error, item
