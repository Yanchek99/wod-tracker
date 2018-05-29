$(document).on 'turbolinks:load', ->
  $('#search').on keyup: ->
    $.get $('#search').attr('action'), $('#search').serialize(), null, 'script'
    false
