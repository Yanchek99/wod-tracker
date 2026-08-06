import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "details", "caret"]
  static values = { expanded: Boolean }

  toggle() {
    this.expandedValue = !this.expandedValue
  }

  expandedValueChanged() {
    this.detailsTarget.hidden = !this.expandedValue
    this.toggleTarget.setAttribute("aria-expanded", this.expandedValue.toString())
    this.caretTarget.textContent = this.expandedValue ? "▴" : "▾"
  }
}
