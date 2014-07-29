Promise = require 'bluebird'
Models = require './Models'


module.exports = class Permissions

  # @private
  # @property [Models] An instance of the models.
  models: null

  # @private
  # @property [Boolean]
  default_is_allowed: false

  # Requires and instance of the db to connect to models.
  #
  # @param db [Database]
  constructor: (@db) ->
    @models = Models @db.connection()

  # Checks if the user is allowed to do the specified action.
  #
  # @todo This should be memoized with a configurable ttl.
  # @param user [Integer, User]
  # @param blueprint [Blueprint]
  # @param action [String]
  is_allowed: (user, blueprint, action) ->
    p = Promise.pending()

    @get_group user
    .then (group) =>
      new @models.Permission
        group_id: group.id
        type: 'blueprint'
        resource: blueprint.get_permission_resource()
        action: action
      .fetch().then (permission) =>
        if permission
          p.fulfill permission.get 'is_allowed'
        else
          p.fulfill @default_is_allowed
      .catch (error) ->
        p.reject error

    p.promise

  # Gets a group.
  #
  # @private
  # @param user [Integer,User]
  # @return [Promise]
  get_group: (user) ->
    p = Promise.pending()

    new @models.User
      id: @get_user_id user
    .fetch
      withRelated: 'group'
    .then (user) ->
      p.fulfill user.related 'group'
    .catch (error) ->
      p.reject error

    p.promise

  # Gets the user id from a user param.
  #
  # @private
  # @param user [Integer,User] Could be the promary ID of the user, or a fetched
  #   user.
  # @return [Integer]
  get_user_id: (user) ->
    return parseInt user if parseInt user
    user.id
