Blueprint = require '../Blueprint'


module.exports = class BlueprintManager

  extension_dir: '../../extensions'
  blueprint_dir: 'blueprints'

  # For maintaining an internal id cache so we don't have to hit the databse
  # every time.
  #
  # @private
  id_map: {}

  constructor: (@db) ->

  # @return [Database]
  database: ->
    @db

  # Returns a new instance of the specified blueprint.
  get: (extension, name) ->
    definition = @blueprint_definition extension, name
    new Blueprint @, extension, name, definition

  blueprint_definition: (extension, name) ->
    require @blueprint_path extension, name

  blueprint_path: (extension, name) ->
    "#{@extension_dir}/#{extension}/#{@blueprint_dir}/#{name}"

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
        if result.length
          id = result[0]['id'] or null
          if id
            @_add_id_to_map extension, name, id

          callback error, id
        else
          # Or create the id
          @create_id extension, name, callback

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
  _add_id_to_map: (extension, name, id) ->
    @id_map["#{extension}:#{name}"] = id

  # @private
  _get_id_from_map: (extension, name) ->
    @id_map["#{extension}:#{name}"] or null
