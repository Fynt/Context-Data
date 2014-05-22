Blueprints = require './lib/Blueprints'
blueprints = new Blueprints

post = blueprints.create 'blog', 'Post'

post.title = "Test Post"
post.body = "Hello, World!"

console.log post.title
console.log post.body
console.log post.test()

post.save()
post.save()
