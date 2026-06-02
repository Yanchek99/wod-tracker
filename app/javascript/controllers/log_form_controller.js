import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  calculateReps(event) {
    var $repFields, $value, field, reps, results, rounds
    $value = $(event.target).val().split('+')
    rounds = parseInt($value[0]) || 0
    reps = parseInt($value[1]) || 0
    $repFields = $(this.element).find('.reps-field')
    results = []
    for (var i = 0; i < $repFields.length; i++) {
      results.push(this.calculateResult($repFields[i], rounds, reps))
    }
    return results
  }

  calculateResult($field, rounds, reps) {
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
}
