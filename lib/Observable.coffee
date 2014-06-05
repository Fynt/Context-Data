Observer = require './Observer'


module.exports = class Observable
  # @private
  # @property [Array<Observer>]
  observers: []

  # @param observer [Observer]
  add_observer: (observer) ->
    if observer instanceof Observer
      @observers.push observer

  # @param event [String]
  notify: (event) ->
    for observer in @observers
      observer.update event, @
