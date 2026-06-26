import { Controller } from "@hotwired/stimulus"

// Shows the ascending-ladder start/step fields only when the workout is shaped like an AMRAP
// (a time cap, no fixed rounds, no interval) — the only shape an open-ended ladder applies to.
// Records whether a ladder is active on the form so each exercise can reveal its cadence field.
export default class extends Controller {
  static targets = ["row", "rounds", "time", "interval", "start", "input"]

  connect() {
    this.toggle()
  }

  toggle(event) {
    if (!this.hasRowTarget) return

    this.rowTarget.hidden = !this.amrapShaped
    if (this.rowTarget.hidden && event) this.clearInputs()
    this.broadcast()
  }

  broadcast() {
    const active = !this.rowTarget.hidden && this.filled(this.hasStartTarget && this.startTarget)
    const form = this.element.closest("form")
    if (form) form.dataset.ladderActive = active ? "true" : "false"
    this.dispatch("change", { target: document, detail: { active } })
  }

  get amrapShaped() {
    const hasTime = this.filled(this.hasTimeTarget && this.timeTarget)
    const hasRounds = this.filled(this.hasRoundsTarget && this.roundsTarget)
    const hasInterval = this.filled(this.hasIntervalTarget && this.intervalTarget)

    return hasTime && !hasRounds && !hasInterval
  }

  filled(target) {
    return Boolean(target) && target.value.trim() !== ""
  }

  clearInputs() {
    this.inputTargets.forEach((input) => {
      input.value = ""
    })
  }
}
