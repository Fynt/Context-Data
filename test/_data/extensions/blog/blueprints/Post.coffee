module.exports =
  title:
    type: 'String'
  body:
    type: 'Text'
  category:
    belongs_to: 'Category'
  comments:
    has_many: 'Comment'
