import { Controller } from "@hotwired/stimulus"

// Dynamically adds/removes reps-per-set number inputs so an optional array field
// (movement_logs[][set_breakdown][]) can be posted as an ordered list, without requiring a
// fixed number of sets up front.
export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()

    this.containerTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML)
  }

  remove(event) {
    event.preventDefault()

    event.currentTarget.closest(".set-breakdown-row").remove()
  }
}
