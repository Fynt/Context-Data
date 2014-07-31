Controller = require '../lib/Controller'
Models = require '../lib/Models'


module.exports = class UserController extends Controller

  # @property [User]
  user_model: null

  initialize: ->
    database = @server.database()
    @user_model = Models(database.connection()).User

  respond_with_user: (user) ->
    @respond
      id: user.id
      group: user.get 'group_id'
      email: user.get 'email'
      name: user.get 'name'
      created_at: user.get 'created_at'
      updated_at: user.get 'updated_at'

  login_action: ->
    email = @form.email
    password = @form.password

    if not email or not password
      return @abort 400, "Email and password is required."

    user = @user_model.forge
      email: email

    user.fetch().then =>
      if user.check_password password
        @session.user_id = user.id
        @respond_with_user user

        # Update last_login
        user.set('last_login': new Date).save()
      else
        @abort 401, "Authentication failed."
    .catch (error) =>
      @abort 401, error

  register_action: ->
    email = @form.email
    password = @form.password

    user = @user_model.forge
      email: email
    user.set_password password

    user.save().then =>
      @response.redirect '/user/session'
    .catch (error) =>
      @abort 500, error

  session_action: ->
    if @session.user_id?
      user = new @user_model id: parseInt @session.user_id

      user.fetch().then =>
        @respond_with_user user
      .catch (error) =>
        @abort 404, "User no longer exists."
    else
      @abort 403, "Login required."

  logout_action: ->
    @session.destroy (error) =>
      if error
        return @abort 500, "There was an error while logging out."

      @response.redirect 'back'
