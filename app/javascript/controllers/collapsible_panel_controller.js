import { Controller } from "@hotwired/stimulus"

// A panel body that starts collapsed on phones and open on desktop. A locked panel is always open on desktop.
export default class extends Controller {
  static targets = ["body", "toggle"]
  static values = { locked: Boolean }

  connect() {
    this.set(this.desktop)
  }

  toggle() {
    if (this.locksOpen) return

    this.set(this.bodyTarget.hidden)
  }

  set(open) {
    this.bodyTarget.hidden = !open
    this.toggleTarget.setAttribute("aria-expanded", String(open))
    this.element.classList.toggle("is-collapsed", !open)
  }

  get desktop() {
    return window.matchMedia("(min-width: 768px)").matches
  }

  get locksOpen() {
    return this.lockedValue && this.desktop
  }
}
