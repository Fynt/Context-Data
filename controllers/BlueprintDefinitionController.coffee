BlueprintController = require './BlueprintController'


module.exports = class BlueprintDefinitionController extends BlueprintController

  definition_action: ->
    blueprint = @get_blueprint()
    @respond blueprint.definition
