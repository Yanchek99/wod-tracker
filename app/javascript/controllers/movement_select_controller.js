import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"
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

        post('/movements.json', {
          body: { movement: { name } },
          responseKind: 'json'
        })
          .then(response => {
            if (!response.ok) throw new Error(`HTTP ${response.status}`)

            return response.json
          })
          .then(callback)
          .catch(error => {
            console.error('Failed to create movement', error)
            callback()
          })
      },
      load(query, callback) {
        get('/movements.json', {
          query: { query },
          responseKind: 'json'
        })
          .then(response => {
            if (!response.ok) throw new Error(`HTTP ${response.status}`)

            return response.json
          })
          .then(callback)
          .catch(error => {
            console.error('Failed to load movements', error)
            callback()
          })
      }
    })
  }
}
