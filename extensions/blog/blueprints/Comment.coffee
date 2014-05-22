Blueprint = require '../../../lib/Blueprint'


module.exports = class BlogComment extends Blueprint
  body:
    type: Blueprint.Text
