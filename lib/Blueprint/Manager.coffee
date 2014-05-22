module.exports = class BlueprintManager

  extension_dir: '../extensions'
  blueprint_dir: 'blueprints'

  constructor: (@db) ->

  # Returns a new instance of the specified blueprint.
  get: (extension, name) ->
    BlueprintClass = @blueprint_class(extension, blueprint)
    new BlueprintClass @

  blueprint_class: (extension, blueprint) ->
    require @blueprint_path extension, blueprint

  blueprint_path: (extension, blueprint) ->
    "#{@extension_dir}/#{extension}/#{@blueprint_dir}/#{blueprint}"
