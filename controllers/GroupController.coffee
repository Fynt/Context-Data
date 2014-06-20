Controller = require '../lib/Controller'
Models = require '../lib/Models'


module.exports = class GroupController extends Controller

  # @property [Group]
  group_model: null

  initialize: ->
    database = @server.database()
    @group_model = Models(database.connection()).Group
