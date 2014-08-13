Controller = require '../lib/Controller'
FileModel = require '../models/FileModel'
ImageModel = require '../models/ImageModel'
ImageResizer = require '../lib/Image/Resizer'


module.exports = class ImageController extends Controller
  resize_params: ->
    file_id: @params.id
    scale: Number @params.scale or 1
    width: parseInt @params.width or 0
    height: parseInt @params.height or 0
    crop_origin_x: parseInt @params.crop_origin_x or 0
    crop_origin_y: parseInt @params.crop_origin_y or 0
    extension: @params.format

  find_image: (done) ->
    resize_params = @resize_params()
    ImageModel.findOne
      where:
        'file_id': resize_params.file_id
        'scale': resize_params.scale
        'width': resize_params.width
        'height': resize_params.height
        'crop_origin_x': resize_params.crop_origin_x
        'crop_origin_y': resize_params.crop_origin_y
        'extension': resize_params.extension,
      done

  resize_image: (done) ->
    FileModel.findById @params.id, (error, file) =>
      return @abort 500 if error
      return @abort 404 if not file

      resizer = new ImageResizer file.storage(), @resize_params()

      # Stream the data for the resized image so we can render the image before
      # saving it to storage, which helps keep resizing-on-the-fly feel speedy.
      resizer.write_to_stream (mimetype, image_stream) =>
        @content_type mimetype
        image_stream.pipe @response

      @create_image file, resizer

  create_image: (file) ->
    # We need a new instance of the resizer because it seems the streams are
    # shared, which causes some funky behaviour, yet calling the stream a
    # second time flushes the resize, so we're back to the original image.
    resizer = new ImageResizer file.storage(), @resize_params()

    # Create a new image based on the resize params.
    image = new ImageModel @resize_params()
    resizer.write_to_image image, (image) ->
      image.save()

  find_or_resize_image: (done) ->
    @find_image (error, image) =>
      if image
        done image
      else
        @resize_image (image) ->
          done image if image

  show_action: ->
    @find_or_resize_image (image) =>
      if image
        @respond image.storage().read()
