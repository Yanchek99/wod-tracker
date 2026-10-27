import { Controller } from "@hotwired/stimulus"

// A panel body that starts collapsed on phones and open on desktop. A locked panel is always open on desktop, where
// its toggle is disabled. The state follows the viewport across the breakpoint (e.g. rotating a phone).
export default class extends Controller {
  static targets = ["body", "toggle"]
  static values = { locked: Boolean }

  connect() {
    this.query = window.matchMedia("(min-width: 768px)")
    this.onViewportChange = () => this.apply()
    this.query.addEventListener("change", this.onViewportChange)
    this.apply()
  }

  disconnect() {
    this.query.removeEventListener("change", this.onViewportChange)
  }

  toggle() {
    if (this.locksOpen) return

    this.set(this.bodyTarget.hidden)
  }

  apply() {
    this.set(this.desktop)
    this.toggleTarget.disabled = this.locksOpen
  }

  set(open) {
    this.bodyTarget.hidden = !open
    this.toggleTarget.setAttribute("aria-expanded", String(open))
    this.element.classList.toggle("is-collapsed", !open)
  }

  get desktop() {
    return this.query.matches
  }

  get locksOpen() {
    return this.lockedValue && this.desktop
  }
}
