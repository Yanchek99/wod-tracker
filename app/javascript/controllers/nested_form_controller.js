import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    positionExercises: Boolean
  }

  connect() {
    this.afterInsert = this.afterInsert.bind(this)
    $(this.element).on('cocoon:after-insert.nested-form', this.afterInsert)
  }

  disconnect() {
    $(this.element).off('cocoon:after-insert.nested-form', this.afterInsert)
  }

  afterInsert(_event, insertedFields) {
    if (this.positionExercisesValue) {
      insertedFields.find("input[name*='position']").val($('.exercise').length)
    }
  }
}
