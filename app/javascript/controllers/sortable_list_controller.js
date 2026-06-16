import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.sortable = Sortable.create(this.containerTarget, {
      animation: 150,
      draggable: ".nested-fields:not([hidden])",
      filter: "input, select, textarea, .ts-control, .ts-dropdown, trix-editor, [contenteditable]",
      onEnd: () => this.refresh()
    })

    this.refresh()
  }

  disconnect() {
    this.sortable?.destroy()
  }

  refresh() {
    this.items.forEach((item, index) => {
      const positionInput = item.querySelector('input[name$="[position]"]')
      if (positionInput) positionInput.value = index + 1
    })
  }

  get items() {
    return Array.from(this.containerTarget.querySelectorAll(":scope > .nested-fields:not([hidden])"))
  }
}
