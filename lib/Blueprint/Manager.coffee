module.exports = class BlueprintManager

  extension_dir: '../../extensions'
  blueprint_dir: 'blueprints'

  # For maintaining an internal id cache so we don't have to hit the databse
  # every time.
  #
  # @private
  id_map: {}

  constructor: (@db) ->

  # Returns a new instance of the specified blueprint.
  get: (extension, name) ->
    BlueprintClass = @blueprint_class(extension, name)
    new BlueprintClass @, extension, name

  blueprint_class: (extension, name) ->
    require @blueprint_path extension, name

  blueprint_path: (extension, name) ->
    "#{@extension_dir}/#{extension}/#{@blueprint_dir}/#{name}"

  get_id: (extension, name, callback) ->
    # We need to see if we can get the id from cache first.
    id = @_get_id_from_map extension, name
    if id
      return callback null, id

    # ...otherwise we hit the DB.
    @db.table('type').select(['id'])
      .where(extension: 'blog', name: 'Post')
      .exec (error, result) =>
        if result
          id = result[0]['id'] or null
          if id
            @_add_id_to_map extension, name, id

          callback error, id
        else
          # Or create the id
          @create_id extension, name, callback

  create_id: (extension, name, callback) ->
    @db.table('type')
      .insert(extension: extension, name: name)
      .exec (error, result) =>
        id = result[0]['id'] or null
        if id
          @_add_id_to_map extension, name, id

        callback error, id

  # @private
  _add_id_to_map: (extension, name, id) ->
    @id_map["#{extension}:#{name}"] = id

  # @private
  _get_id_from_map: (extension, name) ->
    @id_map["#{extension}:#{name}"] or null
