module.exports = class SearchAdapter

  # @abstract
  # @param data [Object]
  # @return [Promise]
  add: (data) ->
    throw new Error "Method `add` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  # @param id [String]
  # @return [Promise]
  get: (id) ->
    throw new Error "Method `get` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  # @param id [String]
  # @return [Promise]
  del: (id) ->
    throw new Error "Method `del` needs to be implemented in
    #{@constructor.name}."

  # @abstract
  # @param query [String, Object]
  # @return [Promise]
  find: (query) ->
    throw new Error "Method `find` needs to be implemented in
    #{@constructor.name}."
