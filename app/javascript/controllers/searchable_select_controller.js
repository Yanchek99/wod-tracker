import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Turns a plain <select> into a type-to-search list (no creating new options).
export default class extends Controller {
  connect() {
    if (this.element.tomselect) return

    this.select = new TomSelect(this.element, {
      closeAfterSelect: true,
      maxOptions: null
    })
  }

  disconnect() {
    this.select?.destroy()
  }
}
