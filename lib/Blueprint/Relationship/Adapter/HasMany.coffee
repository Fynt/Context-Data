Adapter = require '../Adapter'


module.exports =  class BlueprintRelationshipAdapterHasMany extends Adapter

  # @param related_item [BlueprintItem]
  add: (related_item, callback) ->
    @item.blueprint.get_id (error, blueprint_id) =>
      related_item.blueprint.get_id (error, related_blueprint_id) =>

        @database().table 'relationship'
        .insert
          parent_blueprint_id: blueprint_id
          parent_data_id: @item.id
          child_blueprint_id: related_blueprint_id
          child_data_id: related_item.id
        .exec (error, ids) ->
          callback()

  # @param filter [Integer, Object]
  # @param limit [Integer]
  find: (filter, limit, callback) ->
    if @item.id
      @relationship.related_blueprint.get_id (error, child_blueprint_id) =>
        if child_blueprint_id
          q = @database().table 'data'
          .select 'data.*'
          .join 'relationship', 'data.id', '=', 'relationship.child_data_id',
          'inner'
          .where 'data.blueprint_id', child_blueprint_id
          .andWhere 'relationship.parent_data_id', @item.id

          if limit
            q.limit limit

          q.exec (error, results) =>
            callback error, @item.blueprint._collection_from_results results
        else
          callback new Error 'Could not get a blueprint_id for child.', null
    else
      callback new Error 'Item has no id.', null

  find_ids: (callback) ->
    if @item.id
      @relationship.related_blueprint.get_id (error, child_blueprint_id) =>
        if child_blueprint_id
          q = @database().table 'data'
          .select 'data.id'
          .join 'relationship', 'data.id', '=', 'relationship.child_data_id',
          'inner'
          .where 'data.blueprint_id', child_blueprint_id
          .andWhere 'relationship.parent_data_id', @item.id

          q.exec (error, results) ->
            callback error, results
        else
          callback new Error 'Could not get a blueprint_id for child.', null
    else
      callback new Error 'Item has no id.', null
