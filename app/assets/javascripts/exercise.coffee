$(document).on 'turbolinks:load', ->
  $('select.exercise-movement').on change: ->
    $movementSelector = $(this)
    $measurementId = $movementSelector.find(":selected").data('measurementid')
    $measurementSelector = $movementSelector.closest('.card').find('select.exercise-measurement')
    $measurementSelector.find('option[value=' + $measurementId + ']').prop('selected', true)
