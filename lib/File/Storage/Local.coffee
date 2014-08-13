fs = require 'fs'
Storage = require '../Storage'


module.exports = class LocalStorage extends Storage

  # Gets the local file path
  #
  # @private
  local_path: ->
    "./data/files/#{@file.source}"

  # Returns the file content
  #
  # @todo Somehow make this more async?
  # @return [Buffer] The file content
  read: ->
    try
      fs.readFileSync @local_path()
    catch e
      console.error e

  write: (data) ->
    try
      fs.writeFileSync @local_path(), data
    catch e
      console.error e
