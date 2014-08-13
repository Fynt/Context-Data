Storage = require '../Storage'

# Mock storage adapter for testing, etc.
module.exports = class MockStorage extends Storage

  read: ->
    "#{@file.source} is a file!"

  write: (data) ->
    console.log data
