import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["distanceUnits"]
  static values = {
    distanceMeasurements: Array
  }

  connect() {
    this.toggleDistanceUnits()
  }

  toggleDistanceUnits(event) {
    const usesDistanceMetric = this.metricSelects.some((select) => {
      const fields = select.closest(".nested-fields")

      return !fields?.hidden && this.distanceMeasurementsValue.includes(select.value)
    })

    this.distanceUnitsTarget.hidden = !usesDistanceMetric

    if (!usesDistanceMetric && event) {
      this.distanceUnitsInput.value = ""
    }
  }

  get metricSelects() {
    return Array.from(this.element.querySelectorAll("select.metric"))
  }

  get distanceUnitsInput() {
    return this.distanceUnitsTarget.querySelector('input[name$="[distance_units_per_rep]"]')
  }
}
