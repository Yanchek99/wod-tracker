import { Controller } from "@hotwired/stimulus"

// Reveals the recording-dimension fields the workout doesn't prescribe by default (e.g. Duration,
// Distance, Calories on a rep/load-only exercise), for logging a scaled substitution the original
// prescription didn't need. Triggered by the Edit button or by changing the movement itself.
export default class extends Controller {
  static targets = ["field", "editButton"]

  reveal() {
    this.fieldTargets.forEach((field) => { field.hidden = false })
    if (this.hasEditButtonTarget) this.editButtonTarget.hidden = true
  }
}
