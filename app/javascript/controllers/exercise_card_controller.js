import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "summaryButton", "summaryText", "editor", "movementSelect",
    "repsInput", "durationInput",
    "loadInput", "femaleLoadInput", "maleLoadInput", "loadUnitSelect",
    "distanceInput", "femaleDistanceInput", "maleDistanceInput", "distanceUnitSelect",
    "caloriesInput", "femaleCaloriesInput", "maleCaloriesInput"
  ]

  static values = {
    expanded: Boolean
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
    this.summaryButtonTarget.setAttribute("aria-expanded", this.expandedValue.toString())
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

    const leading = this.leading()
    const leadingText = leading.text
    const details = this.detailItems()
      .filter((detail) => detail.kind !== leading.kind)
      .map((detail) => detail.text)
    const movementText = [leadingText, this.movementNameForLeadingText(movementName, leadingText)].filter(Boolean).join(" ")

    if (details.length === 0) return movementText

    return `${movementText} (${details.join(" / ")})`
  }

  movementName() {
    if (!this.hasMovementSelectTarget) return ""

    const select = this.movementSelectTarget
    const value = select.value
    if (!value) return ""

    if (select.tomselect) {
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

  leading() {
    if (this.hasDurationInputTarget && this.durationInputTarget.value.trim() !== "") {
      return { kind: "duration", text: this.durationText(this.durationInputTarget.value) }
    }

    if (this.hasDistanceInputTarget && this.distanceInputTarget.value.trim() !== "" && !this.hasAdditionalWorkDetails()) {
      return { kind: "distance", text: this.leadingValueWithUnit(this.distanceInputTarget.value, this.distanceUnit()) }
    }

    if (this.hasCaloriesInputTarget && this.caloriesInputTarget.value.trim() !== "" && !this.hasAdditionalWorkDetails()) {
      return { kind: "calorie", text: this.leadingValueWithUnit(this.caloriesInputTarget.value, "calorie") }
    }

    if (!this.hasRepsInputTarget || this.repsInputTarget.value.trim() === "") return { kind: null, text: "" }
    if (this.repsInputTarget.value.trim() === "0") return { kind: "reps", text: "max reps" }

    return { kind: "reps", text: this.repsInputTarget.value.trim() }
  }

  movementNameForLeadingText(movementName, leadingText) {
    if (!leadingText) return movementName
    if (leadingText === "max reps") return movementName
    if (/^\d+$/.test(leadingText) && parseInt(leadingText, 10) !== 1) return this.pluralizeMovement(movementName)

    return movementName
  }

  detailItems() {
    return [
      { kind: "load", text: this.sexSpecificDetail(this.femaleLoadInputTarget, this.maleLoadInputTarget, this.loadUnit(), "") },
      { kind: "load", text: this.scalarDetail(this.loadInputTarget, this.loadUnit()) },
      { kind: "distance", text: this.sexSpecificDetail(this.femaleDistanceInputTarget, this.maleDistanceInputTarget, this.distanceUnit(), "-") },
      { kind: "distance", text: this.scalarDetail(this.distanceInputTarget, this.distanceUnit()) },
      { kind: "calorie", text: this.sexSpecificDetail(this.femaleCaloriesInputTarget, this.maleCaloriesInputTarget, "calorie", "-") },
      { kind: "calorie", text: this.scalarDetail(this.caloriesInputTarget, "calorie") }
    ].filter(Boolean)
      .filter((detail) => detail.text)
  }

  scalarDetail(input, unit) {
    if (!input || input.value.trim() === "") return null

    return this.valueWithUnit(input.value, unit)
  }

  sexSpecificDetail(femaleInput, maleInput, unit, separator) {
    if (!femaleInput || !maleInput) return null

    const female = femaleInput.value.trim()
    const male = maleInput.value.trim()
    if (female === "" || male === "") return null

    return `♀${female}${separator}${this.singularUnit(unit)} / ♂${male}${separator}${this.singularUnit(unit)}`
  }

  hasAdditionalWorkDetails() {
    return [
      this.loadInputTarget, this.femaleLoadInputTarget, this.maleLoadInputTarget,
      this.femaleDistanceInputTarget, this.maleDistanceInputTarget,
      this.femaleCaloriesInputTarget, this.maleCaloriesInputTarget
    ].some((input) => input && input.value.trim() !== "")
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
    return this.hasLoadUnitSelectTarget && this.loadUnitSelectTarget.value ? this.loadUnitSelectTarget.value : "lb"
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
