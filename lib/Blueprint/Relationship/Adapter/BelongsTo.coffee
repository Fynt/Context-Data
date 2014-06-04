Adapter = require '../Adapter'


module.exports =  class BlueprintRelationshipAdapterBelongsTo extends Adapter

  # @param related_item [BlueprintItem]
  add: (related_item, callback) ->
    @item.blueprint.get_id (error, blueprint_id) =>
      related_item.blueprint.get_id (error, related_blueprint_id) =>

        @database().table 'relationship'
        .insert
          parent_blueprint_id: related_blueprint_id
          parent_data_id: related_item.id
          child_blueprint_id: blueprint_id
          child_data_id: @item.id
        .exec (error, ids) ->
          callback()
