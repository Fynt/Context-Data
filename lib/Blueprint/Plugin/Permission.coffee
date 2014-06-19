BlueprintPlugin = require '../Plugin'


module.exports = class BlueprintPluginPermission extends BlueprintPlugin

  # @param user [Integer,User]
  # @param permissions [Permissions]
  constructor: (@user, @permissions) ->

  # @param blueprint [Blueprint]
  # @return [Promise]
  pre_view: (blueprint) ->
    permissions.is_allowed @user, 'view'

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  pre_save: (blueprint, item) ->
    permissions.is_allowed @user, 'save'

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  pre_publish: (blueprint, item) ->
    permissions.is_allowed @user, 'publis'

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Promise]
  pre_destroy: (blueprint, item) ->
    permissions.is_allowed @user, 'destroy'
