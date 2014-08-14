Promise = require 'bluebird'
Models = require '../lib/Models'
FilesController = require './FilesController'
ImageResizer = require '../lib/Image/Resizer'


module.exports = class ImageController extends FilesController

  initialize: ->
    database = @server.database()
    @file_model = Models(database.connection()).File
    @image_model = Models(database.connection()).Image

  # @return [Object]
  resize_params: ->
    file_id: @params.id
    scale: Number @params.scale or 1
    width: parseInt @params.width or 0
    height: parseInt @params.height or 0
    crop_origin_x: parseInt @params.crop_origin_x or 0
    crop_origin_y: parseInt @params.crop_origin_y or 0
    extension: @params.format

  # @return [Promise]
  find_image: ->
    resize_params = @resize_params()
    @image_model.forge
      'file_id': resize_params.file_id
      'scale': resize_params.scale
      'width': resize_params.width
      'height': resize_params.height
      'crop_origin_x': resize_params.crop_origin_x
      'crop_origin_y': resize_params.crop_origin_y
      'extension': resize_params.extension
    .fetch()

  # @return [Promise]
  resize_image: ->
    new Promise (resolve, reject) =>
      @file_model.forge
        id: @params.id
      .fetch().then (file) =>
        return @abort 404 if not file

        resizer = new ImageResizer @storage_adapter(file), @resize_params()

        # Stream the data for the resized image so we can render the image
        # before saving it to storage, which helps keep resizing-on-the-fly feel
        # speedy.
        resizer.write_to_stream (mimetype, image_stream) =>
          @content_type mimetype
          image_stream.pipe @response

          resolve @create_image(file, resizer)

  # @todo This method pretty much needs to be re-written.
  # @param file [Object]
  # @param resizer [ImageResizer]
  # @return [Promise]
  create_image: (file, resizer) ->
    # We need a new instance of the resizer because it seems the streams are
    # shared, which causes some funky behaviour, yet calling the stream a
    # second time flushes the resize, so we're back to the original image.
    # resizer = new ImageResizer file.storage(), @resize_params()
    #
    # # Create a new image based on the resize params.
    # image = @image_model.forge @resize_params()
    # resizer.write_to_image image, (image) ->
    #   image.save()

    @image_model.forge @resize_params()

  # @return [Promise]
  find_or_resize_image: ->
    new Promise (resolve, reject) =>
      @find_image().then (image) =>
        if image
          resolve image
        else
          @resize_image().then (image) ->
            resolve image

  show_action: ->
    @find_or_resize_image().then (image) =>
      if image
        #@respond @storage_adapter(image).read()
      else
        @abort 404
