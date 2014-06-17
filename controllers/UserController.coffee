Controller = require '../lib/Controller'
Models = require '../lib/Models'


module.exports = class UserController extends Controller

  # @property [User]
  user_model: null

  initialize: ->
    #TODO We need a nicer way to get at the database.
    database = @server.blueprint_manager.database()
    @user_model = Models(database.connection()).User

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
        @response.redirect 'back'
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
        @repond
          id: user.id
          email: user.get 'email'
          group: user.get 'group_id'
      .catch (error) =>
        console.log error
        @abort 404, "User no longer exists."
    else
      @abort 403, "Login required."

  logout_action: ->
    @session.destroy (error) =>
      if error
        return @abort 500, "There was an error while logging out."

      @response.redirect 'back'
