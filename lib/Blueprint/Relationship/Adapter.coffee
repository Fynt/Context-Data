# @abstract
# @see BlueprintRelationship
module.exports = class BlueprintRelationshipAdapter

  # @param item [BlueprintItem]
  constructor: (@item) ->

  # get_children_of_item: (item, extension, name, filter, callback) ->
  #   do_something: ->
  #     if item.id
  #       @manager.get_id extension, name, (error, child_blueprint_id) =>
  #         if child_blueprint_id
  #           q = @database().table 'data'
  #           .select 'data.*'
  #           .where 'data.blueprint_id', child_blueprint_id
  #           .join 'relationship', 'data.blueprint_id', '=',
  #           'relationship.child_blueprint_id'
  #           .andWhere 'relationship.parent_data_id', item.id
  #
  #           q.exec (error, results) =>
  #             callback error, @_collection_from_results results
  #         else
  #           callback new Error 'Could not get a blueprint_id for child.', null
  #     else
  #       callback new Error 'Item has no id.', null
