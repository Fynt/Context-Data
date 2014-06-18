Models = require './Models'


module.exports = class Permission

  group_model: null

  # @param user [Integer,User]
  # @param db [Database]
  constructor: (@user, @db) ->
    @group_model = Models(@db.connection()).Group
