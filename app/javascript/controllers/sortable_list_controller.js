import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.sortable = Sortable.create(this.containerTarget, {
      animation: 150,
      draggable: ".nested-fields:not([hidden])",
      filter: "input, select, textarea, .ts-control, .ts-dropdown, trix-editor, [contenteditable]",
      ghostClass: "workout-sortable-ghost",
      chosenClass: "workout-sortable-chosen",
      dragClass: "workout-sortable-drag",
      onEnd: () => {
        this.refresh()
        this.clearDragClasses()
      }
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

  clearDragClasses() {
    requestAnimationFrame(() => {
      this.containerTarget.querySelectorAll(".sortable-ghost, .sortable-chosen, .sortable-drag, .workout-sortable-ghost, .workout-sortable-chosen, .workout-sortable-drag").forEach((item) => {
        item.classList.remove("sortable-ghost", "sortable-chosen", "sortable-drag", "workout-sortable-ghost", "workout-sortable-chosen", "workout-sortable-drag")
      })
    })
  }

  get items() {
    return Array.from(this.containerTarget.querySelectorAll(":scope > .nested-fields:not([hidden])"))
  }
}
