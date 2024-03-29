bcrypt = require 'bcrypt'


# @todo I hate the way these models are defined, and I feel like we need a
#   proper class for each model.
# @param connection [Object]
# @param search [Search]
models = (connection, search=null) ->
  # Doing this so we don't have to deal with globals.
  bookshelf = require('bookshelf')(connection)

  User = bookshelf.Model.extend
    tableName: 'user'
    hasTimestamps: ['created_at', 'updated_at']
    defaults: {
      group_id: 1 # Admin
    }

    initialize: ->
      @on "saved", (model, attrs, options) ->
        if search?
          search.add model, ['group_id', 'last_login', 'created_at',
            'updated_at']

      @on "destroyed", (model, attrs, options) ->
        if search?
          search.del model

    name: ->
      'User'

    group: ->
      @belongsTo Group

    set_password: (password) ->
      @set 'password', bcrypt.hashSync password, 10

    check_password: (password) ->
      bcrypt.compareSync password, @get('password')

  Group = bookshelf.Model.extend
    tableName: 'group'
    hasTimestamps: ['created_at', 'updated_at']

    initialize: ->
      @on "saved", (model, attrs, options) ->
        if search?
          search.add model, ['created_at', 'updated_at']

      @on "destroyed", (model, attrs, options) ->
        if search?
          search.del model

    name: ->
      'Group'

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
      @belongsTo(Blueprint).through(Data, 'data_id')

  Data = bookshelf.Model.extend
    tableName: 'data'

  Blueprint = bookshelf.Model.extend
    tableName: 'blueprint'

  File = bookshelf.Model.extend
    tableName: 'file'

    images: ->
      @hasMany Image

  Image = bookshelf.Model.extend
    tableName: 'image'

    source: ->
      @belongsTo File

  # Return an object with all the models.
  User: User
  Group: Group
  Permission: Permission
  History: History
  File: File
  Image: Image

module.exports = models
