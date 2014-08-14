Models = require '../lib/Models'
ApiController = require './ApiController'


module.exports = class FilesController extends ApiController

  # @property [String]
  model_name: "file"

  initialize: ->
    database = @server.database()
    @file_model = Models(database.connection()).File

  find_all_action: ->
    @group_model.fetchAll().then (collection) =>
      @respond collection

  find_action: ->
    @file_model.forge
      id: @params.id
    fetch().then (file) =>
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
