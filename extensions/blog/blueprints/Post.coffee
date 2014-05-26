Types = require '../../../lib/Blueprint/Types'


module.exports =
  title:
    type: Types.String
  body:
    type: Types.Text
  comments:
    has_many: 'Comment'
