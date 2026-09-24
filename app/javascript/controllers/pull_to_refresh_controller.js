import { Controller } from "@hotwired/stimulus"

const PULL_THRESHOLD = 70
const MAX_PULL = 120
const HIDDEN_OFFSET = 60

export default class extends Controller {
  connect() {
    if (!this.isStandalone()) return

    this.pulling = false
    this.refreshing = false
    this.startY = 0
    this.currentY = 0

    this.buildIndicator()

    this.onTouchStart = this.handleTouchStart.bind(this)
    this.onTouchMove = this.handleTouchMove.bind(this)
    this.onTouchEnd = this.handleTouchEnd.bind(this)

    this.element.addEventListener("touchstart", this.onTouchStart, { passive: true })
    this.element.addEventListener("touchmove", this.onTouchMove, { passive: false })
    this.element.addEventListener("touchend", this.onTouchEnd)
  }

  disconnect() {
    this.element.removeEventListener("touchstart", this.onTouchStart)
    this.element.removeEventListener("touchmove", this.onTouchMove)
    this.element.removeEventListener("touchend", this.onTouchEnd)
    this.indicator?.remove()
  }

  isStandalone() {
    return window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true
  }

  buildIndicator() {
    this.indicator = document.createElement("div")
    this.indicator.className = "pull-to-refresh-indicator"
    this.indicator.innerHTML = '<div class="spinner-border spinner-border-sm text-white" role="status"></div>'
    document.body.appendChild(this.indicator)
  }

  handleTouchStart(event) {
    if (this.refreshing || window.scrollY > 0) return

    this.pulling = true
    this.startY = event.touches[0].clientY
    this.currentY = this.startY
    this.indicator.classList.add("pull-to-refresh-dragging")
  }

  handleTouchMove(event) {
    if (!this.pulling || this.refreshing) return

    this.currentY = event.touches[0].clientY
    const distance = this.currentY - this.startY

    if (distance <= 0 || window.scrollY > 0) {
      this.pulling = false
      this.resetIndicator()
      return
    }

    event.preventDefault()

    const pull = Math.min(distance, MAX_PULL)
    this.indicator.style.transform = `translate(-50%, ${pull - HIDDEN_OFFSET}px)`
    this.indicator.classList.toggle("pull-to-refresh-ready", pull >= PULL_THRESHOLD)
  }

  handleTouchEnd() {
    if (!this.pulling || this.refreshing) return

    const distance = this.currentY - this.startY
    this.pulling = false
    this.indicator.classList.remove("pull-to-refresh-dragging")

    if (distance >= PULL_THRESHOLD) {
      this.refreshing = true
      this.indicator.classList.add("pull-to-refresh-loading")
      this.indicator.style.transform = `translate(-50%, ${PULL_THRESHOLD - HIDDEN_OFFSET}px)`
      window.location.reload()
    } else {
      this.resetIndicator()
    }
  }

  resetIndicator() {
    this.indicator.style.transform = ""
    this.indicator.classList.remove("pull-to-refresh-ready", "pull-to-refresh-dragging")
  }
}
