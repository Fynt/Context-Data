BlueprintItem = require '../Blueprint/Item'


module.exports = class SearchAdapter

  # Will generate a document name for the search-index.
  #
  # @param data [BlueprintItem, Model]
  # @return [String]
  get_name: (data) ->
    if data instanceof BlueprintItem
      # It's a BlueprintItem
      extension = data.blueprint.extension
      blueprint_slug = data.blueprint.get_slug()
      name = "#{extension}/#{blueprint_slug}:#{data.id}"
    else
      # ...it's a model!
      model_name = data.name()
      name = "#{model_name}:#{data.id}"

    name

  # Lets us get extract the data from the BlueprintItem or Model.
  #
  # @return [BlueprintItem, Model]
  serialize: (data) ->
    if data instanceof BlueprintItem
      result = data.serialize()
      result.id = String(data.id)
    else
      result = data.toJSON()
      result.id = String(result.id)

    result

  # @abstract
  # @param data [BlueprintItem, Model]
  # @param ignore_fields [Array<String>]
  # @return [Promise]
  add: (data, ignore_fields) ->
    throw new Error "Method `add` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  # @param data [BlueprintItem, Model]
  # @return [Promise]
  del: (data) ->
    throw new Error "Method `del` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  # @param query [String]
  # @return [Promise]
  find: (query) ->
    throw new Error "Method `find` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  # @return [Promise]
  info: ->
    throw new Error "Method `info` needs to be implemented in
    #{@constructor.name}."
