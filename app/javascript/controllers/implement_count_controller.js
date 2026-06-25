import { Controller } from "@hotwired/stimulus"

// Shows the implement-count field only for movements that support single/double loading
// (dumbbell, kettlebell). The supported movement ids come from the server; swap that source for
// the equipment taxonomy once it lands.
export default class extends Controller {
  static targets = ["field", "movementSelect"]
  static values = { movementIds: Array }

  connect() {
    this.toggle()
  }

  toggle(event) {
    if (!this.hasFieldTarget || !this.hasMovementSelectTarget) return

    const supported = this.movementIdsValue.includes(Number(this.movementSelectTarget.value))
    this.fieldTarget.hidden = !supported

    if (!supported && event) this.clearInput()
  }

  clearInput() {
    const input = this.fieldTarget.querySelector("input")
    if (input) input.value = ""
  }
}
