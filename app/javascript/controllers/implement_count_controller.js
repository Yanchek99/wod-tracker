import { Controller } from "@hotwired/stimulus"

// Shows the implement-count field only for movements that support single/double loading
// (dumbbell, kettlebell). The supported movement ids come from the server; swap that source for
// the equipment taxonomy once it lands. Where a loadField target is present (the log recording
// form), Implements only shows once Load is itself a relevant/revealed recording dimension --
// otherwise it would be the only visible field for an unprescribed load.
export default class extends Controller {
  static targets = ["field", "movementSelect", "loadField"]
  static values = { movementIds: Array }

  connect() {
    this.toggle()
  }

  toggle(event) {
    if (!this.hasFieldTarget || !this.hasMovementSelectTarget) return

    const supported = this.movementIdsValue.includes(Number(this.movementSelectTarget.value))
    const loadRelevant = !this.hasLoadFieldTarget || !this.loadFieldTarget.hidden
    const show = supported && loadRelevant
    this.fieldTarget.hidden = !show

    if (!show && event) this.clearInput()
  }

  clearInput() {
    const input = this.fieldTarget.querySelector("input")
    if (input) input.value = ""
  }
}
