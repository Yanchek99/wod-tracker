import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    draggableSelector: { type: String, default: ".nested-fields:not([hidden])" },
    handleSelector: { type: String, default: ".workout-sortable-handle" }
  }

  connect() {
    this.sortable = Sortable.create(this.containerTarget, {
      animation: 150,
      draggable: this.draggableSelectorValue,
      handle: this.handleSelectorValue,
      filter: "input, select, textarea, .ts-control, .ts-dropdown, trix-editor, [contenteditable]",
      preventOnFilter: false,
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

  moveWithKeyboard(event) {
    if (!["ArrowUp", "ArrowDown"].includes(event.key)) return

    const item = this.itemContaining(event.target)
    if (!item) return

    event.preventDefault()

    if (event.key === "ArrowUp") {
      this.moveBeforePrevious(item)
    } else {
      this.moveAfterNext(item)
    }

    this.refresh()
    item.querySelector(this.handleSelectorValue)?.focus()
  }

  clearDragState(item) {
    // SortableJS can leave chosen/drag classes behind briefly after drop. Clear
    // once immediately and twice after its animation/microtask cleanup settles.
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
    const elements = Array.from(this.containerTarget.querySelectorAll(selector))
    if (item) elements.push(item)

    return elements
  }

  moveBeforePrevious(item) {
    const previous = this.itemBefore(item)
    if (!previous) return

    this.containerTarget.insertBefore(item, previous)
  }

  moveAfterNext(item) {
    const next = this.itemAfter(item)
    if (!next) return

    this.containerTarget.insertBefore(item, next.nextSibling)
  }

  itemBefore(item) {
    const index = this.items.indexOf(item)
    if (index <= 0) return null

    return this.items[index - 1]
  }

  itemAfter(item) {
    const index = this.items.indexOf(item)
    if (index < 0 || index >= this.items.length - 1) return null

    return this.items[index + 1]
  }

  itemContaining(target) {
    return this.items.find((item) => item.contains(target))
  }

  get items() {
    return Array.from(this.containerTarget.querySelectorAll(`:scope > ${this.draggableSelectorValue}`))
  }
}
