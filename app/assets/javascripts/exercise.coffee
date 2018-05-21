populateExerciseMeasurement = ->
  $('select.exercise-movement').on change: ->
    $movementSelector = $(this)
    $measurementId = $movementSelector.find(":selected").data('measurement-id')
    $measurementSelector = $movementSelector.closest('.card').find('select.exercise-measurement')
    $measurementSelector.find('option[value=' + $measurementId + ']').prop('selected', true)

$(document).on 'turbolinks:load', ->
  populateExerciseMeasurement()
  $('#exercises').on 'cocoon:after-insert', -> populateExerciseMeasurement()
