Blueprint = require '../Blueprint'


module.exports = class BlueprintManager

  extension_dir: '../../extensions'
  blueprint_dir: 'blueprints'

  # For maintaining an internal id cache so we don't have to hit the databse
  # every time.
  #
  # @private
  @id_map: {}

  # @private
  # @param extension [String]
  # @param name [String]
  @add_id_to_map: (extension, name, id) ->
    @id_map["#{extension}:#{name}"] = id

  # @private
  # @param extension [String]
  # @param name [String]
  @get_id_from_map: (extension, name) ->
    @id_map["#{extension}:#{name}"] or null

  # @param db [Database]
  constructor: (@db) ->

  # @return [Database]
  database: ->
    @db

  # Returns a new instance of the specified blueprint.
  # @param extension [String]
  # @param name [String]
  get: (extension, name) ->
    definition = @blueprint_definition extension, name
    new Blueprint @, extension, name, definition

  # @param extension [String]
  # @param name [String]
  blueprint_definition: (extension, name) ->
    require @blueprint_path extension, name

  # @param extension [String]
  # @param name [String]
  blueprint_path: (extension, name) ->
    "#{@extension_dir}/#{extension}/#{@blueprint_dir}/#{name}"

  # @param extension [String]
  # @param name [String]
  get_id: (extension, name, callback) ->
    # We need to see if we can get the id from cache first.
    id = BlueprintManager.get_id_from_map extension, name
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
            BlueprintManager.add_id_to_map extension, name, id

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
          BlueprintManager.add_id_to_map extension, name, id

        callback error, id
