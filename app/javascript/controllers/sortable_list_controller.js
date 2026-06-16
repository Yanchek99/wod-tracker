import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    draggableSelector: { type: String, default: ".nested-fields:not([hidden])" },
    handleSelector: String
  }

  connect() {
    const options = {
      animation: 150,
      draggable: this.draggableSelectorValue,
      fallbackOnBody: true,
      fallbackTolerance: 3,
      filter: "input, select, textarea, .ts-control, .ts-dropdown, trix-editor, [contenteditable]",
      forceFallback: true,
      ghostClass: "workout-sortable-ghost",
      chosenClass: "workout-sortable-chosen",
      dragClass: "workout-sortable-drag",
      invertSwap: true,
      swapThreshold: 0.35,
      onChange: () => this.refresh(),
      onEnd: (event) => {
        this.refresh()
        this.clearDragState(event.item)
      },
      onUnchoose: (event) => this.clearDragState(event.item),
      onUpdate: () => this.refresh()
    }

    if (this.hasHandleSelectorValue) options.handle = this.handleSelectorValue

    this.sortable = Sortable.create(this.containerTarget, options)

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
