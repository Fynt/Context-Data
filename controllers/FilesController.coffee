ApiController = require './ApiController'
#FileModel = require '../models/FileModel'


module.exports = class FilesController extends ApiController

  find_all_action: ->
    @respond []

  find_action: ->
    FileModel.findById @params.id, (error, file) =>
      @abort 500 if error
      @abort 404 if not file

      @respond file

  create_action: ->
    uploaded_file = @request.files.file
    if uploaded_file?
      file = new FileModel
        source: uploaded_file.name
        extension: uploaded_file.extension

      file.save (err, file) =>
        @respond file
    else
      @abort 500

  delete_action: ->
    FileModel.findById @params.id, (error, file) ->
      @abort 500 if error
      @abort 404 if not file

      file.destroy (err) ->
        if file and not error
          @respond file
        else
          @abort 404

  show_action: ->
    FileModel.findById @params.id, (error, file) =>
      if file and not error
        @content_type file.storage().mimetype()
        @respond file.storage().read()
      else
        @abort 404

  # Pretty much the same as the show_file_action, but it sets the correct header
  #   to force the file to be downloaded.
  download_action: ->
    FileModel.findById @params.id, (error, file) =>
      if file and not error
        filename = file.storage().filename()
        @header "Content-Disposition", "inline; filename=\"#{filename}\""
        @content_type "application/force-download"

        @respond file.storage().read()
      else
        @abort 404
