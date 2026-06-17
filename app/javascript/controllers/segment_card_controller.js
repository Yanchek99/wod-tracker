import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["summary", "summaryText", "expandButton", "editor", "nameInput", "roundsInput", "timeInput", "intervalInput"]

  static values = {
    expanded: Boolean
  }

  connect() {
    this.render()
  }

  expand() {
    this.expandedValue = true
  }

  save() {
    const invalidControl = this.editorControls.find((control) => !control.checkValidity())
    if (invalidControl) {
      invalidControl.reportValidity()
      return
    }

    this.summaryTextTarget.textContent = this.summaryText()
    this.expandedValue = false
  }

  expandedValueChanged() {
    this.render()
  }

  render() {
    if (!this.hasEditorTarget) return

    this.summaryTarget.hidden = this.expandedValue
    this.editorTarget.hidden = !this.expandedValue
    this.expandButtonTarget.setAttribute("aria-expanded", this.expandedValue.toString())
  }

  summaryText() {
    const interval = this.intervalInputTarget.value.trim()
    if (interval) return `${interval} of`

    const rounds = this.roundsInputTarget.value.trim()
    if (rounds) return `${rounds} ${rounds === "1" ? "round" : "rounds"} of`

    const seconds = this.timeInSeconds()
    if (seconds > 0) return `As many rounds as possible in ${this.durationText(seconds)}`

    const name = this.nameInputTarget.value.trim()
    return name ? `${name}:` : "New segment"
  }

  timeInSeconds() {
    const value = this.timeInputTarget.value.trim()
    if (value === "") return 0
    if (!value.includes(":")) return parseInt(value, 10) || 0

    const parts = value.split(":").map((part) => parseInt(part, 10) || 0)
    return parts.reduce((total, part) => (total * 60) + part, 0)
  }

  durationText(seconds) {
    if (seconds % 60 === 0) return `${seconds / 60} ${seconds === 60 ? "minute" : "minutes"}`

    return `${seconds} ${seconds === 1 ? "second" : "seconds"}`
  }

  get editorControls() {
    return Array.from(this.editorTarget.querySelectorAll("input, select, textarea"))
  }
}
