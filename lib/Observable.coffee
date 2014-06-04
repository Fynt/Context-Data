Observer = require './Observer'


module.exports = class Observable
  # @private
  # @property [Array<Observer>]
  observers: []

  add_observer: (observer) ->
    if observer instanceof Observer
      @abservers.push observer
