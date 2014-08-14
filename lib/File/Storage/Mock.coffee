FileStorage = require '../Storage'

# Mock storage adapter for testing, etc.
module.exports = class FileStorageMock extends FileStorage

  read: ->
    source = @file.get 'source'
    "#{source} is a file!"

  write: (data) ->
    console.log data
