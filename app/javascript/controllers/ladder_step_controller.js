import { Controller } from "@hotwired/stimulus"

// Shows the per-exercise ladder cadence ("step every N rounds") only when the workout is an
// ascending ladder AND this exercise rides it (no fixed rep count of its own). Reacts both to its
// own reps input and to the workout-level ladder toggle broadcast on the document.
export default class extends Controller {
  static targets = ["field", "reps"]

  connect() {
    this.toggle()
  }

  toggle(event) {
    if (!this.hasFieldTarget || !this.hasRepsTarget) return

    const visible = this.ladderActive && this.repsTarget.value.trim() === ""
    this.fieldTarget.hidden = !visible

    if (!visible && event) this.clearInput()
  }

  get ladderActive() {
    const form = this.element.closest("form")
    return Boolean(form) && form.dataset.ladderActive === "true"
  }

  clearInput() {
    const input = this.fieldTarget.querySelector("input")
    if (input) input.value = ""
  }
}
