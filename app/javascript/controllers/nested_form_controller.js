import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    placeholder: String,
    positionExercises: Boolean
  }

  connect() {
    this.counter = 0
  }

  add(event) {
    event.preventDefault()

    const content = this.template.innerHTML.replaceAll(this.placeholderValue, this.newId())
    this.container.insertAdjacentHTML('beforeend', content)
    this.assignExercisePosition(this.container.lastElementChild)
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

  assignExercisePosition(fields) {
    if (!this.positionExercisesValue) return

    const positionInput = fields.querySelector('input[name$="[position]"]')
    if (!positionInput) return

    positionInput.value = this.element.closest('form').querySelectorAll('.exercise:not([hidden])').length
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
