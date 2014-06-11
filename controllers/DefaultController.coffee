Controller = require '../lib/Controller'

module.exports = class DefaultController extends Controller

  index_action: ->
    @response.sendfile './templates/application.html'

  health_check_action: ->
    @respond "HELLO"
