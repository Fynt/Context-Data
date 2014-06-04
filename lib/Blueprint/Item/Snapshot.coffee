module.exports = class BlueprintItemSnapshot

  # @private
  # @param item [BlueprintItem]
  _create: (item) ->
    if item.id
      @manager.get_id @extension, @name, (error, blueprint_id) =>
        if blueprint_id
          @database().table 'snapshot'
          .insert
            data_id: item.id
            blueprint_id: blueprint_id
            author: 1
            data: item.json()
            created_at: new Date
          .exec()
