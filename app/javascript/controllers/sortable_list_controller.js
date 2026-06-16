import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    draggableSelector: { type: String, default: ".nested-fields:not([hidden])" },
    filterSelector: {
      type: String,
      default: "input, select, textarea, .ts-control, .ts-dropdown, trix-editor, [contenteditable]"
    },
    handleSelector: String
  }

  connect() {
    this.clearDragState = this.clearDragState.bind(this)

    const options = {
      animation: 150,
      draggable: this.draggableSelectorValue,
      fallbackClass: "workout-sortable-fallback",
      fallbackTolerance: 3,
      filter: this.filterSelectorValue,
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
      onStart: () => this.startDrag(),
      onUnchoose: (event) => this.clearDragState(event.item),
      onUpdate: () => this.refresh()
    }

    if (this.hasHandleSelectorValue) options.handle = this.handleSelectorValue

    this.sortable = Sortable.create(this.containerTarget, options)
    this.addReleaseListeners()

    this.refresh()
  }

  disconnect() {
    this.removeReleaseListeners()
    this.sortable?.destroy()
  }

  startDrag() {
    document.body.classList.add("workout-sorting")
  }

  refresh() {
    this.items.forEach((item, index) => {
      const positionInput = item.querySelector('input[name$="[position]"]')
      if (positionInput) positionInput.value = index + 1
    })
  }

  clearDragState(item) {
    [0, 50, 200, 500, 1000].forEach((delay) => {
      setTimeout(() => this.clearDragClasses(item), delay)
    })
  }

  clearDragClasses(item) {
    document.body.classList.remove("workout-sorting")

    this.dragClassElements(item).forEach((element) => {
      element.classList.remove(
        "sortable-ghost",
        "sortable-chosen",
        "sortable-drag",
        "sortable-fallback",
        "workout-sortable-ghost",
        "workout-sortable-chosen",
        "workout-sortable-drag",
        "workout-sortable-fallback"
      )
    })
  }

  dragClassElements(item) {
    const selector = [
      ".sortable-ghost",
      ".sortable-chosen",
      ".sortable-drag",
      ".sortable-fallback",
      ".workout-sortable-ghost",
      ".workout-sortable-chosen",
      ".workout-sortable-drag",
      ".workout-sortable-fallback"
    ].join(", ")
    const elements = Array.from(document.querySelectorAll(selector))
    if (item instanceof Element) elements.push(item)

    return elements
  }

  addReleaseListeners() {
    this.releaseEvents.forEach((eventName) => {
      document.addEventListener(eventName, this.clearDragState, true)
    })
  }

  removeReleaseListeners() {
    this.releaseEvents.forEach((eventName) => {
      document.removeEventListener(eventName, this.clearDragState, true)
    })
  }

  get releaseEvents() {
    return ["dragend", "drop", "mouseup", "pointerup", "touchend"]
  }

  get items() {
    return Array.from(this.containerTarget.querySelectorAll(`:scope > ${this.draggableSelectorValue}`))
  }
}
