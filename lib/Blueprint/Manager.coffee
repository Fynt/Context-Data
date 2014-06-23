fs = require 'fs'
path = require 'path'
Promise = require 'bluebird'
pluralize = require 'pluralize'
Blueprint = require '../Blueprint'
BlueprintPlugins = require '../Blueprint/Plugins'


module.exports = class BlueprintManager

  # The path to the extensions directory.
  #
  # @private
  # @property [String]
  extension_dir: null

  # Basically just a cache for get_extensions at this point.
  #
  # @private
  # @property [Array<String>]
  extensions: []

  # The path within the exensions to the blueprints.
  #
  # @property [String]
  blueprint_dir: 'blueprints'

  # For maintaining an internal id cache so we don't have to hit the databse
  # every time.
  #
  # @private
  # @property [Object]
  id_map: {}

  # @private
  # @property [BlueprintPlugins]
  plugins: null

  # @param db [Database]
  # @param plugins [Array<BlueprintPlugin>]
  # @param extension_dir [String] The path to the extensions directory.
  constructor: (@db, @plugins=[], extension_dir='extensions') ->
    @plugins = new BlueprintPlugins plugins

    root_path = path.dirname require.main.filename
    @extension_dir = "#{root_path}/#{extension_dir}"

  # Gets an instance of the database
  #
  # @return [Database]
  database: -> @db

  # Returns a new instance of the specified blueprint.
  #
  # @param extension [String]
  # @param name [String]
  get: (extension, name) ->
    definition = @blueprint_definition extension, name
    new Blueprint @, extension, name, definition

  # Loads the available extensions.
  #
  # @return [Promise]
  get_extensions: ->
    new Promise (resolve, reject) =>
      if not @extensions.length
        fs.readdir "#{@extension_dir}", (error, files) =>
          if files
            for file in files
              # Need to make sure it's a directory
              if fs.lstatSync("#{@extension_dir}/#{file}").isDirectory()
                @extensions.push file

          resolve @extensions
      else
        resolve @extensions


  # Gets all the registered blueprints for a given extension.
  #
  # @param extension [String]
  # @return [Promise]
  get_blueprints: (extension) ->
    new Promise (resolve, reject) =>
      @database().table('blueprint')
      .select 'id', 'extension', 'name'
      .where 'extension', extension
      .exec (error, blueprints) ->
        # Add the slug.
        for blueprint in blueprints
          blueprint['slug'] = pluralize(blueprint.name).toLowerCase()

        resolve blueprints

  # @param extension [String]
  # @param name [String]
  blueprint_definition: (@extension, @name) ->
    require @blueprint_path extension, name

  # @param extension [String]
  # @param name [String]
  blueprint_path: (extension, name) ->
    class_name = @_blueprint_class_name name
    "#{@extension_dir}/#{extension}/#{@blueprint_dir}/#{class_name}"

  # @param extension [String]
  # @param name [String]
  get_id: (extension, name, callback) ->
    # We need to see if we can get the id from cache first.
    id = @_get_id_from_map extension, name
    if id
      return callback null, id

    # ...otherwise we hit the DB.
    @database().table('blueprint').select(['id'])
      .where(extension: extension, name: name)
      .limit(1)
      .exec (error, result) =>
        if result and result.length
          id = result[0]['id'] or null
          if id
            @_add_id_to_map extension, name, id

          callback error, id
        else
          # Or create the id
          @create_id extension, name, callback

  # @param extension [String]
  # @param name [String]
  create_id: (extension, name, callback) ->
    @database().table('blueprint')
      .insert(extension: extension, name: name)
      .exec (error, ids) =>
        id = null
        if ids and ids.length
          id = ids[0]
          @_add_id_to_map extension, name, id

        callback error, id

  # @private
  # @param extension [String]
  # @param name [String]
  _add_id_to_map: (extension, name, id) ->
    @id_map["#{extension}:#{name}"] = id

  # @private
  # @param extension [String]
  # @param name [String]
  _get_id_from_map: (extension, name) ->
    @id_map["#{extension}:#{name}"] or null

  # @private
  # @param name [String]
  # @return [String]
  _blueprint_class_name: (name) ->
    # Generate a class name from the type
    upper = (s) ->
      s[0].toUpperCase() + s[1..-1].toLowerCase()
    class_name = (name.split('-').map (s) -> upper s).join ''
