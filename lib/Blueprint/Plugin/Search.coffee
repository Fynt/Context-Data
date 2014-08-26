BlueprintPlugin = require '../Plugin'


module.exports = class BlueprintPluginSearch extends BlueprintPlugin

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  pre_save: (blueprint, item) ->
    permissions.is_allowed @user, blueprint, 'save'

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  pre_destroy: (blueprint, item) ->
    permissions.is_allowed @user, blueprint, 'destroy'
