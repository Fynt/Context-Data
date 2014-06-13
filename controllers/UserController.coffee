Controller = require '../lib/Controller'
User = require '../lib/User'


module.exports = class UserController extends Controller

  # @property [User]
  user_model: null

  initialize: ->
    #TODO We need a nicer way to get at the database.
    database = @server.blueprint_manager.database()
    @user = new User database

  login_action: ->
    email = @form.email
    password = @form.password

    @user.find_by_email email, (error, user) =>
      @respond user
