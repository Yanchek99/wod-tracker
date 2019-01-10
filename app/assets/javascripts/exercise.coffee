$(document).on 'turbolinks:load', ->
  $('#exercises').on 'cocoon:after-insert', (e, added_exercise) ->
    added_exercise.find("input[name*='position']").val($('.exercise').length) 
