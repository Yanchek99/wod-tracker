import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["distanceUnits", "distanceValue", "distanceUnitSelect"]

  connect() {
    this.toggleDistanceUnits()
  }

  toggleDistanceUnits(event) {
    const hasDistance =
      this.distanceValueTargets.some((input) => input.value.trim() !== "") ||
      (this.hasDistanceUnitSelectTarget && this.distanceUnitSelectTarget.value !== "")

    this.distanceUnitsTarget.hidden = !hasDistance

    if (!hasDistance && event) {
      this.distanceUnitsInput.value = ""
    }
  }

  get distanceUnitsInput() {
    return this.distanceUnitsTarget.querySelector('input[name$="[distance_units_per_rep]"]')
  }
}
