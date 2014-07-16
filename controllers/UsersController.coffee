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
    'password'
    'verify_pass'
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
    for field in mutable_fields
      if request_body[field]?
        user_data[field] = request_body[field]

    user_data

  find_all_action: ->
    @user_model.fetchAll
      # Hide the password column.
      columns: [
        'id'
        'group_id'
        'email'
        'last_login'
        'updated_at'
        'created_at'
      ]
    .then (collection) =>
      collection.mapThen (user) ->
        user.set 'group', user.get 'group_id'
        user.unset 'group_id'
      .then (collection) =>
        @respond collection

  find_action: ->
    @user_model.forge
      id: @params.id
    .fetch()
    .then (user) =>
      if user
        user.set 'group', user.get 'group_id'
        user.unset 'group_id'

        @respond user
      else
        @abort 404

  update_action: ->
    @user_model.forge
      id: @params.id
    .fetch()
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
          @respond user
      else
        @abort 404

  create_action: ->
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
          @respond user
        .catch (error) =>
          @abort 500, error
      else
        @abort 400, "Passwords do not match."
    else
      @abort 400, "Password is required to create a user."

  delete_action: ->
    @user_model.forge
      id: @params.id
    .destroy()
    .then (user) =>
      @respond user
