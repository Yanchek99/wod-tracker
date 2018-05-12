# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  FontAwesome.dom.i2svg()

$(document).on 'cocoon:after-insert', ->
  FontAwesome.dom.i2svg()
