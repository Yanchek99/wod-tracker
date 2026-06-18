import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    placeholder: String,
    positionExercises: Boolean,
    positionSegments: Boolean
  }

  connect() {
    this.counter = 0
  }

  add(event) {
    event.preventDefault()

    const template = this.templateFor(event.currentTarget.dataset.nestedFormTemplate)
    const placeholderValue = template.dataset.placeholderValue || this.placeholderValue
    const content = template.innerHTML.replaceAll(placeholderValue, this.newId())
    this.container.insertAdjacentHTML('beforeend', content)
    this.assignPosition(this.container.lastElementChild)
    this.dispatch('add')
  }

  remove(event) {
    event.preventDefault()

    const fields = event.target.closest('.nested-fields')
    const destroyInput = fields.querySelector('input[name$="[_destroy]"]')
    destroyInput.value = '1'
    fields.hidden = true
    this.dispatch('remove')
  }

  assignPosition(fields) {
    if (!this.positionExercisesValue && !this.positionSegmentsValue) return

    const positionInput = fields.querySelector('input[name$="[position]"]')
    if (!positionInput) return

    positionInput.value = this.nextPosition()
  }

  nextPosition() {
    const selector = this.positionSegmentsValue ? ':scope > .nested-fields:not([hidden])' : ':scope > .exercise:not([hidden])'
    const positions = Array.from(this.container.querySelectorAll(selector))
      .map(fields => parseInt(fields.querySelector('input[name$="[position]"]')?.value, 10))
      .filter(position => !Number.isNaN(position))

    return Math.max(0, ...positions) + 1
  }

  templateFor(name) {
    if (!name) {
      return this.template
    }

    return this.element.querySelector(`template[data-nested-form-template="${name}"]`) || this.template
  }

  newId() {
    return `${Date.now()}${this.counter++}`
  }

  get container() {
    return this.element.querySelector(':scope > [data-nested-form-target="container"]')
  }

  get template() {
    return this.element.querySelector(':scope > template[data-nested-form-target="template"]')
  }
}
