module.exports = class BlueprintHistory

  # @param db [Database]
  constructor: (@db) ->

  # @return [Database]
  database: ->
    @db

  # Convenience method for registering an action without an item.
  #
  # @param author [Integer]
  # @param action [String]
  register_action: (author, action, callback=null) ->
    if callback
      @register author, action, null, callback
    else
      @register author, action, null, ->

  # @param author [Integer]
  # @param action [String]
  # @param item [BlueprintItem]
  register: (author, action, item, callback) ->
    item_id = null
    if item and item.id?
      item_id = item.id

    # Creating a snapshot here if we need to or not just to simplify the code.
    @create_snapshot item, (error, snapshot_id) =>
      @database().insert 'history',
        author: author
        action: action
        data_id: item_id
        created_at: new Date,
        callback

  # @param item [BlueprintItem]
  create_snapshot: (item, callback) ->
    if item and item.id?
      item.blueprint.get_id (error, blueprint_id) =>
        if blueprint_id
          @database().table 'snapshot'
          .insert
            data_id: item.id
            blueprint_id: blueprint_id
            data: item.json()
          .exec (error, ids) ->
            callback error, snapshot_id
        else
          callback new Error 'Could not get a blueprint_id.', null
    else
      # This isn't really an error condition, just more of a no-op.
      callback null, null
