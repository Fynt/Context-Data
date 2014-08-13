FileStorage = require '../Storage'

# Mock storage adapter for testing, etc.
module.exports = class FileStorageMock extends FileStorage

  read: ->
    "#{@file.source} is a file!"

  write: (data) ->
    console.log data
