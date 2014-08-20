Promise = require 'bluebird'
Observer = require '../Observer'


module.exports = class BlueprintHistory extends Observer

  # @param db [Database]
  constructor: (@db) ->

  # @return [Database]
  database: ->
    @db

  # @param item [BlueprintItem]
  on_save: (item) ->
    @register item.author, "save", item, (error, ids) ->
      # Do nothing

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
    @create_snapshot item
    .then =>
      @database().insert 'history',
        author: author
        action: action
        data_id: item_id
        created_at: new Date,
        callback

  # @param item [BlueprintItem]
  # @return [Promise]
  create_snapshot: (item) ->
    new Promise (resolve, reject) =>
      if item and item.id?
        item.blueprint.get_id (error, blueprint_id) =>
          if blueprint_id
            @database().table 'snapshot'
            .insert
              data_id: item.id
              blueprint_id: blueprint_id
              data: item.json()
            .exec (error, ids) ->
              resolve ids[0]
          else
            reject new Error 'Could not get a blueprint_id.'
      else
        # This isn't really an error condition, just more of a no-op.
        resolve null
