import { Controller } from "@hotwired/stimulus"

// Reveals an exercise's ladder controls only when the workout is an ascending ladder. The "constant"
// (ladder-exempt) checkbox shows whenever a ladder is active; the cadence ("step every N rounds")
// shows only when this exercise actually rides the ladder, i.e. it is not marked constant. Reacts to
// the workout-level ladder toggle broadcast on the document and to its own constant checkbox.
export default class extends Controller {
  static targets = ["exemptField", "stepEveryField", "exempt"]

  connect() {
    this.toggle()
  }

  toggle() {
    const active = this.ladderActive

    if (this.hasExemptFieldTarget) this.exemptFieldTarget.hidden = !active
    if (this.hasStepEveryFieldTarget) this.stepEveryFieldTarget.hidden = !(active && !this.exemptChecked)
  }

  get ladderActive() {
    const form = this.element.closest("form")
    return Boolean(form) && form.dataset.ladderActive === "true"
  }

  get exemptChecked() {
    return this.hasExemptTarget && this.exemptTarget.checked
  }
}
