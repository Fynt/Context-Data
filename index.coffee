config = require('konfig')()
Database = require './lib/Database'
BlueprintManager = require './lib/Blueprint/Manager'

database = new Database config.db
manager = new BlueprintManager database


# Create a post
# post_blueprint = manager.get 'blog', 'Post'
#
# post = post_blueprint.create()
# post.title = 'First Post!'
# post.body = 'Hello, World!'
#
# post.save ->
#   console.log post.id, post.json()

# Create a comment
# comment_blueprint = manager.get 'blog', 'Comment'
#
# comment = comment_blueprint.create()
# comment.body = 'Cool post, bro!'
#
# comment.save ->
#   console.log comment.id, comment.json()

# Find a post
post_blueprint = manager.get 'blog', 'Post'

post_blueprint.find_one 26, (error, post) ->
  post.comments (error, comments) ->
    console.log error, comments
