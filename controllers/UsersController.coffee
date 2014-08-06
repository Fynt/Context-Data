Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class UsersController extends ApiController

  # @property [String]
  model_name: "user"

  # @property [User]
  user_model: null

  # An array of keys representing the model properties that can be updated
  #   through the API.
  #
  # @property [Array<String>]
  mutable_fields: [
    'group_id'
    'email'
    'name'
    'password'
    'verify_pass'
  ]

  # Used to prevent us from sending the password field, etc.
  #
  # @property [Array<String>]
  public_fields: [
    'id'
    'group_id'
    'email'
    'name'
    'last_login'
    'updated_at'
    'created_at'
  ]

  initialize: ->
    database = @server.database()
    @user_model = Models(database.connection()).User

  # @return [Object]
  user_data: ->
    request_body = @request_body()

    # Set the group id properly.
    if request_body.group?
      request_body.group_id = parseInt request_body.group

    # Populate the user_data object.
    user_data = {}
    for field in @mutable_fields
      if request_body[field]?
        user_data[field] = request_body[field]

    user_data

  # Converts a User to a plain object that's better suited and cleaned up for
  #   sending in an API response.
  #
  # @param [User]
  # @return [Object]
  user_to_object: (user) ->
    user = user.toJSON()

    user.group = user.group_id
    delete user.group_id
    delete user.password

    user

  find_all_action: ->
    @check_permissions(@user_model, 'view').then (is_allowed) =>
      if is_allowed
        @user_model.fetchAll
          columns: @public_fields
          withRelated: ['group']
        .then (collection) =>
          groups = []
          collection.mapThen (user) ->
            user = user.toJSON()

            groups.push user.group
            user.group = user.group.id
            delete user.group_id

            user
          .then (collection) =>
            @respond
              user: collection
              group: groups
            , false
      else
        @abort 401

  find_action: ->
    @check_permissions(@user_model, 'view').then (is_allowed) =>
      if is_allowed
        @user_model.forge
          id: @params.id
        .fetch
          columns: @public_fields
          withRelated: ['group']
        .then (user) =>
          if user
            user = user.toJSON()

            group = user.group
            user.group = user.group_id
            delete user.group_id

            @respond
              user: user
              group: group
            , false
          else
            @abort 404
      else
        @abort 401

  update_action: ->
    @check_permissions(@user_model, 'save').then (is_allowed) =>
      if is_allowed
        @user_model.forge
          id: @params.id
        .fetch
          columns: @public_fields
        .then (user) =>
          if user
            user_data = @user_data()

            if user_data.password?
              # Check the verify password.
              if user_data.password == user_data.verify_pass
                user.set_password user_data.password
              else
                return @abort 400, "Passwords do not match."

              # Won't be needing these anymore.
              delete user_data.password
              delete user_data.verify_pass

            user.set user_data
            user.save()
            .then (user) =>
              @respond @user_to_object user
            .catch (error) =>
              @abort 500, error
          else
            @abort 404
      else
        @abort 401

  create_action: ->
    @check_permissions(@user_model, 'destroy').then (is_allowed) =>
      if is_allowed
        user_data = @user_data()
        if user_data.password?
          # Check the verify password.
          if user_data.password == user_data.verify_pass
            # Create a user and set the password
            user = @user_model.forge()
            user.set_password user_data.password

            # Won't be needing these anymore.
            delete user_data.password
            delete user_data.verify_pass

            user.set user_data
            user.save()
            .then (user) =>
              @respond @user_to_object user
            .catch (error) =>
              @abort 500, error
          else
            @abort 400, "Passwords do not match."
        else
          @abort 400, "Password is required to create a user."
      else
        @abort 401

  delete_action: ->
    @check_permissions(@user_model, 'destroy').then (is_allowed) =>
      if is_allowed
        @user_model.forge
          id: @params.id
        .destroy()
        .then (user) =>
          @respond @user_to_object user
      else
        @abort 401
