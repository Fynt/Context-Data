bcrypt = require 'bcrypt'


# @todo I hate the way these models are defined, and I feel like we need a
#   proper class for each model.
# @param connection [Object]
# @param search [Search]
models = (connection, search=null) ->
  # Doing this so we don't have to deal with globals.
  bookshelf = require('bookshelf')(connection)

  ContextModel = bookshelf.Model.extend
    get_id: (callback) ->
      if @id?
        callback null, @id
      else
        @save (error, item) ->
          callback error, item.id

  User = ContextModel.extend
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

  Group = ContextModel.extend
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

  Permission = ContextModel.extend
    tableName: 'permission'
    hasTimestamps: ['created_at', 'updated_at']

    group: ->
      @belongsTo Group

  History = ContextModel.extend
    tableName: 'history'

    author: ->
      @belongsTo User, 'author'

    blueprint: ->
      @belongsTo(Blueprint).through(Data, 'data_id')

  Data = ContextModel.extend
    tableName: 'data'

  Blueprint = ContextModel.extend
    tableName: 'blueprint'

  File = ContextModel.extend
    tableName: 'file'

    images: ->
      @hasMany Image

  Image = ContextModel.extend
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
