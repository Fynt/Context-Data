module.exports = class BlueprintRelationship

  constructor: (type) ->
    @adapter = load_adapter type

  # @private
  # @param type [String] The adapter type
  load_adapter: (type) ->
    # Generate a class name from the type
    upper = (word) ->
      word[0].toUpperCase() + word[1..-1].toLowerCase()
    class_name = (type.split('_').map (word) -> upper word).join ''

    # Create class name
    adapter_class = require "./Relationship/Adapter/#{class_name}"
    new adapter_class
