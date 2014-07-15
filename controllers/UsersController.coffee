Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class UsersController extends ApiController

  # @property [String]
  model_name: "user"

  # @property [User]
  user_model: null

  initialize: ->
    database = @server.database()
    @user_model = Models(database.connection()).User

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
      @respond collection

  find_action: ->
    @user_model.forge
      id: @params.id
    .fetch()
    .then (user) =>
      if user
        @respond user
      else
        @abort 404

  update_action: ->
    @user_model.forge
      id: @params.id
    .fetch()
    .then (user) =>
      if user
        user.set(@request_body()).save()
        .then (user) =>
          @respond user
      else
        @abort 404

  create_action: ->
    user_data = @request_body()

    # Set the group id properly.
    if user_data.group?
      user_data.group_id = parseInt user_data.group
    delete user_data.group

    user = @user_model.forge user_data
    user.save()
    .then =>
      @respond user
    .catch (error) =>
      @abort 500, error

  delete_action: ->
    @user_model.forge
      id: @params.id
    .destroy()
    .then (user) =>
      @respond user
