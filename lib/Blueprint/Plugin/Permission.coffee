module.exports = class BlueprintPlugin

  # @param permissions [Permissions]
  constructor: (@permissions) ->

  # @param blueprint [Blueprint]
  # @return [Boolean]
  view: (blueprint) -> true

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Boolean]
  save: (blueprint, item) -> true

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Boolean]
  publish: (blueprint, item) -> true

  # @param blueprint [Blueprint]
  # @param item [BlueprintItem]
  # @return [Boolean]
  destroy: (blueprint, item) -> true
