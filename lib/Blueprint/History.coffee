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

      #TODO register snapshot

    @db.insert 'history',
      author: author
      action: action
      data_id: item_id
      created_at: new Date,
      callback

  find_by_author: (author, callback) ->


  find_by_action: (action, callback) ->
