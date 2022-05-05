const logs = {
  initialize() {
    // Create the listener function
   var calculateResult = function($field, rounds, reps) {
     return function() {
       var additionalReps, originalReps, willCarryOver
       originalReps = parseInt($field.data('original-reps'))
       willCarryOver = (reps / originalReps) > 1
       additionalReps = reps
       if (willCarryOver) {
         additionalReps = originalReps
         reps -= originalReps
       } else {
         reps = 0
       }
       return $field.prop('value', (rounds * originalReps) + additionalReps)
     }
   }

    $(document).on('turbolinks:load', function() {
      return $('input[data-auto-calc-reps=true]').on({
        keyup: function() {
          var $repFields, $value, field, reps, results, rounds
          $value = $(this).val().split('+')
          rounds = parseInt($value[0]) || 0
          reps = parseInt($value[1]) || 0
          $repFields = $(this.form).find('.reps-field')
          results = []
          for (var i = 0; i < $repFields.length; i++) {
            results.push(calculateResult($repFields[i], rounds, reps))
          }
          return results
        }
      })
    })
  }
}

export default logs
