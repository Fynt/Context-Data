Blueprint = require '../../../lib/Blueprint'


module.exports = class BlogPost extends Blueprint
  title:
    type: Blueprint.String
  body:
    type: Blueprint.Text
  comments:
    has_many: 'blog/Comment'
