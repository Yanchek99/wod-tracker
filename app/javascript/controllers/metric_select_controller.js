import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    if (this.element.tomselect) return

    new TomSelect(this.element, {
      sortField: 'name'
    })
  }
}
