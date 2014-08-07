fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'
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

  # Gets blueprint info by slugs.
  #
  # @param extension [String]
  # @param slug [String] The blueprint slug.
  # @return [Promise]
  get_extension_and_name_by_slug: (extension, slug) ->
    new Promise (resolve, reject) =>
      @database().table('blueprint')
      .first 'extension', 'name'
      .where 'extension', extension
      .where 'slug', slug
      .then (result) ->
        resolve result
      .catch (error) ->
        reject error

  # Gets blueprint info by item id.
  #
  # @param item_id [Integer]
  # @return [Promise]
  get_extension_and_name_by_item_id: (item_id) ->
    new Promise (resolve, reject) =>
      @database().table('blueprint')
      .first 'extension', 'name'
      .innerJoin 'data', 'blueprint.id', 'data.blueprint_id'
      .where 'data.id', item_id
      .then (result) ->
        resolve result
      .catch (error) ->
        reject error

  # Loads the available extensions.
  #
  # @return [Promise]
  get_extensions: ->
    new Promise (resolve, reject) =>
      if not @extensions.length
        fs.readdir "#{@extension_dir}", (error, files) =>
          for extension in files or []
            # Need to make sure it's a directory
            if fs.lstatSync("#{@extension_dir}/#{extension}").isDirectory()
              @extensions.push extension

          resolve @extensions
      else
        resolve @extensions

  # Registers all the blueprints in each extension.
  #
  # @return [Promise]
  register_blueprints: ->
    promises = []
    @get_extensions().then (extensions) =>
      for extension in extensions
        blueprints_dir = "#{@extension_dir}/#{extension}/#{@blueprint_dir}"

        # Find all the files.
        fs.readdir blueprints_dir, (error, files) =>
          for blueprint_def in files or []
            if fs.lstatSync("#{blueprints_dir}/#{blueprint_def}").isFile()
              # Get the blueprint name.
              blueprint_name = blueprint_def.split('.')[0]
              promises.push @get_id extension, blueprint_name

    # This will resolve when we have all the ids.
    Promise.all promises

  # Gets all the registered blueprints for a given extension.
  #
  # @param params [Object] The object to build the query. Should be sanitized by
  #   the controller.
  # @return [Promise]
  get_blueprints: (params) ->
    new Promise (resolve, reject) =>
      q = @database().table('blueprint')
      .select 'id', 'extension', 'name', 'slug'

      # Build the query based on the params.
      for k of params
        q.where k, params[k]

      q.exec (error, blueprints) ->
        if error
          reject error
        else
          resolve blueprints

  # Gets blueprint info by id.
  #
  # @param blueprint_id [Integer]
  # @return [Promise]
  get_blueprint_by_id: (blueprint_id) ->
    new Promise (resolve, reject) =>
      @database().table('blueprint')
      .select 'id', 'extension', 'name', 'slug'
      .where 'id', blueprint_id
      .then (result) ->
        resolve result
      .catch (error) ->
        reject error

  # Gets the blueprint definition.
  #
  # @param extension [String]
  # @param name [String]
  # @return [Object] The object returned from yaml.load
  blueprint_definition: (extension, name) ->
    class_name = @_blueprint_class_name name
    blueprint_path =
      "#{@extension_dir}/#{extension}/#{@blueprint_dir}/#{class_name}.yml"

    yaml.safeLoad fs.readFileSync(blueprint_path, 'utf8')

  # Gets the id for a given blueprint.
  #
  # @param extension [String]
  # @param name [String]
  # @return [Promise]
  get_id: (extension, name) ->
    new Promise (resolve, reject) =>
      # We need to see if we can get the id from cache first.
      id = @_get_id_from_map extension, name
      if id
        return resolve id

      # ...otherwise we hit the DB.
      @database().table('blueprint').select(['id'])
        .where(extension: extension, name: name)
        .limit(1)
        .exec (error, result) =>
          if result and result.length
            id = result[0]['id'] or null
            if id
              @_add_id_to_map extension, name, id

            if not error
              resolve id
            else
              reject error
          else
            # Or create the id because there was no result.
            @create_id extension, name
            .then (id) ->
              resolve id

  # Inserts a row for the blueprint and returns an id.
  #
  # @param extension [String]
  # @param name [String]
  # @return [Promise]
  create_id: (extension, name) ->
    new Promise (resolve, reject) =>
      @database().table('blueprint')
      .insert
        extension: extension
        name: @_blueprint_label name
        slug: @_blueprint_slug name
      .exec (error, ids) =>
        id = null
        if ids and ids.length
          id = ids[0]
          @_add_id_to_map extension, name, id

        if not error
          resolve id
        else
          reject error

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

  # Converts blueprint slug name to a proper ClassName.
  #
  # @private
  # @param name_or_slug [String]
  # @return [String]
  _blueprint_class_name: (name_or_slug) ->
    # Generate a class name from the type
    upper = (s) ->
      s[0].toUpperCase() + s[1..-1].toLowerCase()
    class_name = (name_or_slug.split('-').map (s) -> upper s).join ''

  # Returns a singularized label.
  #
  # @private
  # @param name [String]
  # @return [String]
  _blueprint_label: (name) ->
    name = name[0].toUpperCase() + name[1..-1]
    pluralize.singular name

  # Returns a pluralized, lowercase name for the blueprint slug.
  #
  # @private
  # @param name [String]
  # @return [String]
  _blueprint_slug: (name) ->
    pluralize(name).toLowerCase()
