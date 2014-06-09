Controller = require '../lib/Controller'

module.exports = class DefaultController extends Controller

  health_check_action: ->
    @respond "HELLO"
