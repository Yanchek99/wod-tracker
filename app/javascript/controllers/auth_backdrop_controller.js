import { Controller } from "@hotwired/stimulus"

// iOS 26 Safari uses the root background color for the status bar (page top) and for the area behind its
// toolbar (page end), so switch it between the gradient's two ends as the page scrolls.
export default class extends Controller {
  connect() {
    this.update = this.update.bind(this)
    window.addEventListener("scroll", this.update, { passive: true })
    window.addEventListener("resize", this.update)
    this.update()
  }

  disconnect() {
    window.removeEventListener("scroll", this.update)
    window.removeEventListener("resize", this.update)
    document.documentElement.style.backgroundColor = ""
  }

  update() {
    const root = document.documentElement
    const remaining = root.scrollHeight - window.innerHeight - window.scrollY
    root.style.backgroundColor = remaining <= 120 && window.scrollY > 0 ? "#15803d" : "#052e16"
  }
}
