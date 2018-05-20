$(document).on 'turbolinks:load', ->
  $('input[data-auto-calc-reps=true]').on keyup: ->
    $value = $(this).val().split('+')
    rounds = parseInt($value[0])
    reps = parseInt($value[1]) || 0
    console.log("Rounds: "+rounds+" Reps: "+reps)
    $repFields = $(this.form).find('.reps-field')
    for field in $repFields
      do ->
        $field = $(field)
        originalReps = parseInt($field.data('original-reps'))
        willCarryOver = (reps / originalReps) > 1
        additionalReps = reps
        if (willCarryOver)
          additionalReps = originalReps
          reps -= originalReps
        else
          reps = 0
        $field.prop('value', (rounds * originalReps) + additionalReps)
