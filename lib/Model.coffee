ModelItem = require './Model/Item'


module.exports = class Model

  # @private
  # @property [String] The name of the database table.
  table_name: null

  # @private
  # @property [ModelItem]
  item_class: ModelItem

  # @param db [Database]
  constructor: (@db) ->
    if not @table_name?
      throw new Error "The `table_name` needs to be set in
      #{@constructor.name}."

  # Gets an instance of the database
  #
  # @return [Database]
  database: ->
    @db

  # @return [Object] An instance of the Knex query builder.
  table: ->
    @database.table @table_name

  # Creates a ModelItem.
  #
  # @param item_data [Object] The row data.
  # @return [ModelItem]
  create: (item_data) ->
    item = new @item_class @
    if item_data?
      item.initialize item_data

    item

  
