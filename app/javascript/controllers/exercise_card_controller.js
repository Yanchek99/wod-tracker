import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "summaryButton", "summaryText", "expandButton", "editor", "movementSelect",
    "repsInput", "durationInput",
    "loadInput", "femaleLoadInput", "maleLoadInput",
    "distanceInput", "femaleDistanceInput", "maleDistanceInput", "distanceUnitSelect",
    "caloriesInput", "femaleCaloriesInput", "maleCaloriesInput"
  ]

  static values = {
    expanded: Boolean,
    loadUnit: { type: String, default: "lb" }
  }

  connect() {
    this.handleOpening = this.handleOpening.bind(this)
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    document.addEventListener("exercise-card:opening", this.handleOpening)
    document.addEventListener("click", this.handleDocumentClick, true)

    this.render()
  }

  disconnect() {
    document.removeEventListener("exercise-card:opening", this.handleOpening)
    document.removeEventListener("click", this.handleDocumentClick, true)
  }

  expand() {
    if (this.expandedValue) return
    if (!this.requestExclusiveOpen()) return

    this.expandedValue = true
  }

  save() {
    this.saveIfValid()
  }

  handleOpening(event) {
    if (event.detail.card === this || !this.expandedValue) return
    if (this.saveIfValid()) return

    event.preventDefault()
  }

  handleDocumentClick(event) {
    if (!this.expandedValue || this.element.contains(event.target) || this.tomSelectOwns(event.target)) return

    this.saveIfValid()
  }

  requestExclusiveOpen() {
    return this.element.dispatchEvent(new CustomEvent("exercise-card:opening", {
      bubbles: true,
      cancelable: true,
      detail: { card: this }
    }))
  }

  saveIfValid() {
    if (!this.validateEditor()) return false

    this.summaryTextTarget.textContent = this.summaryText()
    this.expandedValue = false

    return true
  }

  expandedValueChanged() {
    this.render()
  }

  render() {
    if (!this.hasEditorTarget) return

    this.editorTarget.hidden = !this.expandedValue
    this.summaryButtonTarget.hidden = this.expandedValue
    this.expandButtonTarget.setAttribute("aria-expanded", this.expandedValue.toString())
  }

  validateEditor() {
    this.clearMovementError()

    if (!this.movementName()) {
      this.showMovementError("Select a movement")
      return false
    }

    const invalidControl = this.editorControls.find((control) => !control.checkValidity())
    if (!invalidControl) return true

    invalidControl.reportValidity()
    return false
  }

  showMovementError(message) {
    this.movementSelectTarget.setCustomValidity(message)
    this.movementSelectTarget.tomselect?.control_input.focus()

    if (this.movementErrorElement) {
      this.movementErrorElement.textContent = message
      return
    }

    const error = document.createElement("div")
    error.className = "invalid-feedback d-block"
    error.dataset.exerciseCardMovementError = "true"
    error.textContent = message

    this.movementWrapper.classList.add("is-invalid")
    this.movementWrapper.insertAdjacentElement("afterend", error)
  }

  clearMovementError() {
    if (!this.hasMovementSelectTarget) return

    this.movementSelectTarget.setCustomValidity("")
    this.movementWrapper.classList.remove("is-invalid")
    this.movementErrorElement?.remove()
  }

  summaryText() {
    const movementName = this.movementName()
    if (!movementName) return "New exercise"

    const metrics = this.prescriptionMetrics()
    const leading = this.leading(metrics)
    const leadingText = leading.text
    const movementText = [
      leadingText,
      this.movementNameForLeadingMetric(movementName, leading.metric)
    ].filter(Boolean).join(" ")
    const details = this.additionalMetrics(metrics, leading.metric)

    if (details.length === 0) return movementText

    return `${movementText} (${this.additionalMetricsText(details)})`
  }

  movementName() {
    if (!this.hasMovementSelectTarget) return ""

    const select = this.movementSelectTarget
    const value = select.value
    if (!value) return ""

    if (select.tomselect) {
      // TomSelect stores server-provided Movement JSON with a name key; created options may only expose text.
      return select.tomselect.options[value]?.name || select.tomselect.options[value]?.text || ""
    }

    return select.selectedOptions[0]?.textContent.trim() || ""
  }

  get editorControls() {
    return Array.from(this.editorTarget.querySelectorAll("input, select, textarea"))
  }

  get movementWrapper() {
    return this.movementSelectTarget.tomselect?.wrapper || this.movementSelectTarget
  }

  get movementErrorElement() {
    return this.movementWrapper.parentElement.querySelector("[data-exercise-card-movement-error]")
  }

  tomSelectOwns(target) {
    return target.closest(".ts-dropdown") && this.element.contains(this.movementSelectTarget.tomselect?.wrapper)
  }

  prescriptionMetrics() {
    return [
      this.metric("rep", "rep", this.repsInputTarget),
      this.metric("duration", "seconds", this.durationInputTarget),
      this.metric("load", this.loadUnit(), this.loadInputTarget, this.femaleLoadInputTarget, this.maleLoadInputTarget),
      this.metric("distance", this.distanceUnit(), this.distanceInputTarget, this.femaleDistanceInputTarget, this.maleDistanceInputTarget),
      this.metric("calorie", "calorie", this.caloriesInputTarget, this.femaleCaloriesInputTarget, this.maleCaloriesInputTarget)
    ].filter(Boolean)
  }

  metric(kind, measurement, valueInput, femaleInput = null, maleInput = null) {
    if (!valueInput) return null

    const value = valueInput.value.trim()
    const femaleValue = femaleInput?.value.trim() || ""
    const maleValue = maleInput?.value.trim() || ""
    if (value === "" && femaleValue === "" && maleValue === "") return null

    return {
      kind,
      measurement,
      value: ["rep", "calorie"].includes(kind) && value === "0" ? "" : value,
      femaleValue,
      maleValue,
      sexSpecific: femaleValue !== "" && maleValue !== ""
    }
  }

  leading(metrics) {
    const durationMetric = metrics.find((metric) => this.durationMetric(metric) && metric.value !== "")
    if (durationMetric) return { metric: durationMetric, text: this.durationText(durationMetric.value) }

    const leadingWorkMetric = this.leadingWorkMetric(metrics)
    if (leadingWorkMetric) {
      return { metric: leadingWorkMetric, text: this.leadingWorkMetricText(leadingWorkMetric) }
    }

    const repMetric = metrics.find((metric) => metric.kind === "rep")
    if (!repMetric) return { metric: null, text: "" }
    if (repMetric.value === "" && !repMetric.sexSpecific) return { metric: repMetric, text: "max reps" }

    return { metric: repMetric, text: this.metricUnitText(repMetric) }
  }

  leadingWorkMetric(metrics) {
    const candidate = metrics.find((metric) => this.visibleMetric(metric) && this.leadingWorkMetricKind(metric))
    if (!candidate) return null

    return metrics.every((metric) => !this.visibleMetric(metric) || metric === candidate || this.structuralSingleRepMetric(metric))
      ? candidate
      : null
  }

  additionalMetrics(metrics, leadingMetric) {
    return metrics
      .filter((metric) => metric.kind !== "rep")
      .filter((metric) => metric !== leadingMetric)
      .filter((metric) => !this.durationMetric(metric))
      .filter((metric) => this.visibleMetric(metric))
      .sort((left, right) => this.compareOrders(this.additionalMetricDisplayOrder(left), this.additionalMetricDisplayOrder(right)))
  }

  additionalMetricsText(metrics) {
    if (metrics.length > 1 && metrics.every((metric) => metric.sexSpecific)) {
      return this.sexSpecificMetricsText(metrics)
    }

    return metrics.map((metric) => this.metricUnitText(metric)).join(" / ")
  }

  sexSpecificMetricsText(metrics) {
    const orderedMetrics = [...metrics].sort((left, right) => (
      this.compareOrders(this.sexSpecificMetricDisplayOrder(left), this.sexSpecificMetricDisplayOrder(right))
    ))
    const femaleValues = orderedMetrics.map((metric) => this.sexSpecificMetricValueText(metric, metric.femaleValue))
    const maleValues = orderedMetrics.map((metric) => this.sexSpecificMetricValueText(metric, metric.maleValue))

    return `♀${femaleValues.join(" + ")} / ♂${maleValues.join(" + ")}`
  }

  metricUnitText(metric) {
    if (metric.sexSpecific) return this.sexSpecificMetricUnitText(metric)
    if (metric.value === "") return this.valueWithUnit("1", metric.measurement)
    if (metric.kind === "rep") return metric.value === "1" ? "" : metric.value
    if (this.durationMetric(metric)) return this.durationText(metric.value)

    return this.valueWithUnit(metric.value, metric.measurement)
  }

  sexSpecificMetricUnitText(metric) {
    const unit = this.singularUnit(metric.measurement)
    const separator = this.loadMeasurement(unit) ? "" : "-"

    return `♀${metric.femaleValue}${separator}${unit} / ♂${metric.maleValue}${separator}${unit}`
  }

  sexSpecificMetricValueText(metric, value) {
    const unit = metric.measurement === "foot" ? "ft" : this.singularUnit(metric.measurement)
    const separator = this.loadMeasurement(unit) || unit === "ft" ? "" : "-"

    return `${value}${separator}${unit}`
  }

  leadingWorkMetricText(metric) {
    if (metric.sexSpecific) return `${metric.maleValue}/${metric.femaleValue} ${this.singularUnit(metric.measurement)}`

    return this.leadingValueWithUnit(metric.value, metric.measurement)
  }

  movementNameForLeadingMetric(movementName, metric) {
    if (!metric) return movementName
    if (metric.kind === "rep" && metric.value === "" && !metric.sexSpecific) return movementName
    if (this.durationMetric(metric)) {
      return this.repsInputTarget.value.trim() === "0" ? this.pluralizeMovement(movementName) : movementName
    }
    if (metric.kind === "rep" && parseInt(metric.value, 10) > 1) return this.pluralizeMovement(movementName)

    return movementName
  }

  visibleMetric(metric) {
    return metric.value !== "" || metric.sexSpecific
  }

  durationMetric(metric) {
    return metric.kind === "duration"
  }

  leadingWorkMetricKind(metric) {
    return metric.kind === "calorie" || metric.kind === "distance"
  }

  structuralSingleRepMetric(metric) {
    return metric.kind === "rep" && metric.value === "1"
  }

  additionalMetricDisplayOrder(metric) {
    if (metric.kind === "calorie" || metric.kind === "distance") return [0, 1]
    if (metric.kind === "load") return [1, 0]

    return [1, 1]
  }

  sexSpecificMetricDisplayOrder(metric) {
    if (metric.kind === "load") return [0, 1]
    if (metric.kind === "distance") return [1, 0]

    return [1, 1]
  }

  compareOrders(left, right) {
    return left[0] - right[0] || left[1] - right[1]
  }

  loadMeasurement(unit) {
    return ["lb", "kg"].includes(unit)
  }

  valueWithUnit(value, unit) {
    const cleanValue = value.trim()
    const cleanUnit = this.singularUnit(unit)

    return cleanValue === "1" ? `${cleanValue} ${cleanUnit}` : `${cleanValue} ${this.pluralizeUnit(cleanUnit)}`
  }

  leadingValueWithUnit(value, unit) {
    return `${value.trim()} ${this.singularUnit(unit)}`
  }

  durationText(value) {
    const totalSeconds = parseInt(value, 10)
    if (Number.isNaN(totalSeconds)) return value.trim()

    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60

    if (hours > 0) return `${hours}:${this.pad(minutes)}:${this.pad(seconds)}`

    return `${minutes}:${this.pad(seconds)}`
  }

  loadUnit() {
    return this.loadUnitValue
  }

  distanceUnit() {
    return this.hasDistanceUnitSelectTarget && this.distanceUnitSelectTarget.value ? this.distanceUnitSelectTarget.value : "meter"
  }

  singularUnit(unit) {
    if (unit === "feet") return "foot"
    if (unit.endsWith("s")) return unit.slice(0, -1)

    return unit
  }

  pluralizeUnit(unit) {
    if (unit === "foot") return "feet"
    if (unit === "inch") return "inches"
    if (unit.endsWith("s")) return unit

    return `${unit}s`
  }

  pluralizeMovement(movementName) {
    if (movementName.endsWith("s")) return movementName
    if (movementName.endsWith("y")) return `${movementName.slice(0, -1)}ies`

    return `${movementName}s`
  }

  pad(value) {
    return value.toString().padStart(2, "0")
  }
}
