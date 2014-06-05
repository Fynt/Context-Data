module.exports = class Observer

  # Recieve a notification.
  #
  # @params event [String]
  # @params subject [Observable]
  update: (event, subject) ->
    # See if the method exists.
    if @["on_#{event}"]?
      # Call the event method.
      @["on_#{event}"] subject
