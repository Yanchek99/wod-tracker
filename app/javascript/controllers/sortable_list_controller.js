import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    draggableSelector: { type: String, default: ".nested-fields:not([hidden])" }
  }

  connect() {
    this.sortable = Sortable.create(this.containerTarget, {
      animation: 150,
      draggable: this.draggableSelectorValue,
      filter: "input, select, textarea, .ts-control, .ts-dropdown, trix-editor, [contenteditable]",
      ghostClass: "workout-sortable-ghost",
      chosenClass: "workout-sortable-chosen",
      dragClass: "workout-sortable-drag",
      onEnd: (event) => {
        this.refresh()
        this.clearDragState(event.item)
      },
      onUnchoose: (event) => this.clearDragState(event.item)
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

  clearDragState(item) {
    [0, 50, 200].forEach((delay) => {
      setTimeout(() => this.clearDragClasses(item), delay)
    })
  }

  clearDragClasses(item) {
    this.dragClassElements(item).forEach((element) => {
      element.classList.remove("sortable-ghost", "sortable-chosen", "sortable-drag", "workout-sortable-ghost", "workout-sortable-chosen", "workout-sortable-drag")
    })
  }

  dragClassElements(item) {
    const selector = ".sortable-ghost, .sortable-chosen, .sortable-drag, .workout-sortable-ghost, .workout-sortable-chosen, .workout-sortable-drag"
    const elements = Array.from(document.querySelectorAll(selector))
    if (item) elements.push(item)

    return elements
  }

  get items() {
    return Array.from(this.containerTarget.querySelectorAll(`:scope > ${this.draggableSelectorValue}`))
  }
}
