Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class FilesController extends ApiController

  # @property [String]
  model_name: "file"

  initialize: ->
    database = @server.database()
    @file_model = Models(database.connection()).File

  # Gets the file storage class.
  #
  # @param file [Object] A model result that has source and extension
  #   properties.
  # @return [FileStorage]
  storage_adapter: (file) ->
    file_storage = @server.config.server.file_storage
    storage_class = require "../lib/File/Storage/#{file_storage}"

    new storage_class file

  find_all_action: ->
    @group_model.fetchAll().then (collection) =>
      @respond collection

  find_action: ->
    @file_model.forge
      id: @params.id
    .fetch().then (file) =>
      @abort 404 if not file

      @respond file

  create_action: ->
    uploaded_file = @request.files.file
    if uploaded_file?
      @file_model.forge
        source: uploaded_file.name
        extension: uploaded_file.extension
      .save().then (file) =>
        @respond file
      .catch (error) =>
        @abort 500, error
    else
      @abort 500

  delete_action: ->
    @file_model.forge
      id: @params.id
    .destroy()
    .then (file) =>
      @respond file

  # show_action: ->
  #   FileModel.findById @params.id, (error, file) =>
  #     if file and not error
  #       @content_type file.storage().mimetype()
  #       @respond file.storage().read()
  #     else
  #       @abort 404
  #
  # # Pretty much the same as the show_file_action, but it sets the correct header
  # #   to force the file to be downloaded.
  # download_action: ->
  #   FileModel.findById @params.id, (error, file) =>
  #     if file and not error
  #       filename = file.storage().filename()
  #       @header "Content-Disposition", "inline; filename=\"#{filename}\""
  #       @content_type "application/force-download"
  #
  #       @respond file.storage().read()
  #     else
  #       @abort 404
