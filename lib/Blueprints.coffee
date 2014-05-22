module.exports = class Blueprints

  constructor: (@extension_dir='../extensions', @blueprint_dir='blueprints') ->

  # Returns a new instance of the specified blueprint.
  create: (extension, blueprint) ->
    BlueprintClass = @get_class(extension, blueprint)
    new BlueprintClass @

  get_class: (extension, blueprint) ->
    require @get_class_path extension, blueprint

  get_class_path: (extension, blueprint) ->
    "#{@extension_dir}/#{extension}/#{@blueprint_dir}/#{blueprint}"
