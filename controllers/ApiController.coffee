Controller = require '../lib/Controller'


module.exports = class ApiController extends Controller

  # @param result [Object, String] The value you want to send.
  # @param model_name [String] The value you want to send.
  respond: (result, model_name) ->
    if not model_name?
      throw new Error "You'll need to supply a model name."

    model_result = {}
    model_result[model_name] = result

    @response.json model_result
