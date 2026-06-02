import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  calculateReps(event) {
    var repFields, value, reps, results, rounds
    value = event.target.value.split('+')
    rounds = parseInt(value[0]) || 0
    reps = parseInt(value[1]) || 0
    repFields = this.element.querySelectorAll('.reps-field')
    results = []
    for (var i = 0; i < repFields.length; i++) {
      results.push(this.calculateResult(repFields[i], rounds, reps))
    }
    return results
  }

  calculateResult(field, rounds, reps) {
    return function() {
      var additionalReps, originalReps, willCarryOver
      originalReps = parseInt(field.dataset.originalReps)
      willCarryOver = (reps / originalReps) > 1
      additionalReps = reps
      if (willCarryOver) {
        additionalReps = originalReps
        reps -= originalReps
      } else {
        reps = 0
      }
      return field.value = (rounds * originalReps) + additionalReps
    }
  }
}
