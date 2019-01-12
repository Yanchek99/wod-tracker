$(document).on('turbolinks:load', function() {
  return $('input[data-auto-calc-reps=true]').on({
    keyup: function() {
      var $repFields, $value, field, i, len, reps, results, rounds;
      $value = $(this).val().split('+');
      rounds = parseInt($value[0]) || 0;
      reps = parseInt($value[1]) || 0;
      $repFields = $(this.form).find('.reps-field');
      results = [];
      for (i = 0, len = $repFields.length; i < len; i++) {
        field = $repFields[i];
        results.push((function() {
          var $field, additionalReps, originalReps, willCarryOver;
          $field = $(field);
          originalReps = parseInt($field.data('original-reps'));
          willCarryOver = (reps / originalReps) > 1;
          additionalReps = reps;
          if (willCarryOver) {
            additionalReps = originalReps;
            reps -= originalReps;
          } else {
            reps = 0;
          }
          return $field.prop('value', (rounds * originalReps) + additionalReps);
        })());
      }
      return results;
    }
  });
});
