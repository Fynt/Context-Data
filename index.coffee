config = require('konfig')()
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'

database = new Database config.db
manager = new BlueprintManager database

post_blueprint = manager.get 'blog', 'Post'

# Create a post
post = post_blueprint.create()
post.title = 'First Post!'
post.body = 'Hello, World!'

console.log post.comments()

#
# post.save ->
#   console.log post.id, post.json()
