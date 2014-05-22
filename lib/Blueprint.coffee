module.exports = class Blueprint
  @String = 'String'
  @Text = 'Text'

  _type: null

  _id: null
  _data: {}

  constructor: (@blueprints) ->
    @_type = @constructor.name
    @_register_properties()

  initialize: ->

  get: (key) ->
    @_data[key] or fallback

  set: (key, value) ->
    @_data[key] = value

  save: ->
    if @_id?
      @update()
    else
      @create()

  update: ->
    console.log "Updated..."

  create: ->
    @_id = 1
    console.log "Created..."

  _register_properties: ->
    properties = {}

    for key, value of @
      if value instanceof Object and value.type?
        do (key) ->
          properties[key] =
            get: ->
              @get key
            set: (value) ->
              @set key, value

    Object.defineProperties @, properties
