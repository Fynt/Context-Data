bcrypt = require 'bcrypt'


# @param connection [Object]
models = (connection) ->
  # Doing this so we don't have to deal with globals.
  bookshelf = require('bookshelf')(connection)

  User = bookshelf.Model.extend
    tableName: 'user'
    hasTimestamps: ['created_at', 'updated_at']
    defaults: {
      group_id: 1 # Admin
    }

    group: ->
      @belongsTo Group

    set_password: (password) ->
      @set 'password', bcrypt.hashSync password, 10

    check_password: (password) ->
      bcrypt.compareSync password, @get('password')

  Group = bookshelf.Model.extend
    tableName: 'group'
    hasTimestamps: ['created_at', 'updated_at']

    users: ->
      @hasMany User

    permissions: ->
      @hasMany Permission

  Permission = bookshelf.Model.extend
    tableName: 'permission'
    hasTimestamps: ['created_at', 'updated_at']

    group: ->
      @belongsTo Group

  History = bookshelf.Model.extend
    tableName: 'history'

    author: ->
      @belongsTo User, 'author'

    blueprint: ->
      @belongsTo(Blueprint, 'id').through(Data, 'data_id')

  Data = bookshelf.Model.extend
    tableName: 'data'

  Blueprint = bookshelf.Model.extend
    tableName: 'blueprint'

  # Return an object with all the models.
  User: User
  Group: Group
  Permission: Permission
  History: History

module.exports = models
