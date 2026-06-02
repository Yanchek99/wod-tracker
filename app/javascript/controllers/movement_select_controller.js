import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    if (this.element.tomselect) return

    new TomSelect(this.element, {
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
      sortField: 'name',
      create(input, callback) {
        const name = input.trim()

        if (!name) {
          callback()
          return
        }

        $.ajax({
          type: "POST",
          url: "/movements",
          dataType: "json",
          data: { movement: { name: name } },
          success(res) {
            if (res) {
              callback(res)
            }
          },
          error(xhr) {
            console.error("Failed to create movement", xhr.responseJSON || xhr.responseText)
            callback()
          }
        })
      },
      load(query, callback) {
        $.getJSON("/movements.json", { query: query }, function(data) {
          callback(data)
        })
      }
    })
  }
}
