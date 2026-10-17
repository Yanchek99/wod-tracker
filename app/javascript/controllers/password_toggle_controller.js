import { Controller } from "@hotwired/stimulus"

// Show/hide toggle for a password field: swaps the input between password and text.
export default class extends Controller {
  static targets = ["input", "button", "maskedIcon", "revealedIcon"]

  toggle() {
    const reveal = this.inputTarget.type === "password"
    this.inputTarget.type = reveal ? "text" : "password"
    this.maskedIconTarget.toggleAttribute("hidden", reveal)
    this.revealedIconTarget.toggleAttribute("hidden", !reveal)
    this.buttonTarget.setAttribute("aria-label", reveal ? "Hide password" : "Show password")
    this.buttonTarget.setAttribute("aria-pressed", reveal)
  }
}
