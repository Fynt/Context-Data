# @abstract
# @see BlueprintRelationship
module.exports = class BlueprintRelationshipAdapter

  # @param relationship [BlueprintRelationship]
  # @param item [BlueprintItem]
  constructor: (@relationship, @item) ->

  # @return [Database]
  database: ->
    @relationship.database()

  # @abstract
  add: (related_item, callback) ->
    throw new Error "Method `add` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  find: (filter, limit, callback) ->
    throw new Error "Method `find` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  find_ids: (callback) ->
    throw new Error "Method `find_ids` needs to be implemented in
    #{@constructor.name}."
