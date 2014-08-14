Models = require './Models'
Promise = require 'bluebird'
Blueprint = require './Blueprint'


module.exports = class Permissions

  # @private
  # @property [Models] An instance of the models.
  models: null

  # The default value that the is_allowed method will fall back to.
  #
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
  # @param asset [Blueprint, String, Array] A the asset that the permissions are
  #   applied to.
  # @param action [String]
  # @return [Promise]
  is_allowed: (user, asset, action) ->
    p = Promise.pending()

    if asset instanceof Blueprint
      type = 'blueprint'
      resource = asset.get_permission_resource()
    else if asset instanceof String
      type = 'extension'
      resource = asset
    else
      type = asset[0]
      resource = asset[1]

    @get_group user
    .then (group) =>
      if group
        new @models.Permission
          group_id: group.id
          type: type
          resource: resource
          action: action
        .fetch().then (permission) =>
          if permission
            p.fulfill permission.get 'is_allowed'
          else
            p.fulfill @default_is_allowed
        .catch (error) ->
          p.reject error
      else
        # There was no group, so return the default, but we should consider
        # enforcing a visitor group rather than ever change this default.
        p.fulfill @default_is_allowed

    p.promise

  # Gets a group.
  #
  # @todo Maybe it makes sense to return a visitor group if we can set that up
  #   as a mandatory default.
  # @private
  # @param user [Integer, User]
  # @return [Promise]
  get_group: (user) ->
    p = Promise.pending()

    # We can't get a group for a null user (visitor).
    if not user
      p.fulfill null
    else
      new @models.User
        id: @get_user_id user
      .fetch
        withRelated: 'group'
      .then (user) ->
        if user
          p.fulfill user.related 'group'
        else
          p.fulfill null
      .catch (error) ->
        p.reject error

    p.promise

  # Gets the user id from a user param.
  #
  # @private
  # @param user [Integer, User] Could be the promary ID of the user, or a
  #   fetched user.
  # @return [Integer]
  get_user_id: (user) ->
    return parseInt user if parseInt user
    user.id
