import { Controller } from "@hotwired/stimulus"

// Drives both WebAuthn ceremonies: `register` adds a passkey to the signed-in user (account page),
// `authenticate` signs in with one (login page). Both POST to the options URL for a challenge,
// hand it to the browser/OS (Face ID, Touch ID, Windows Hello...), then POST the result to the URL.
export default class extends Controller {
  static targets = ["supported", "label", "error"]
  static values = { optionsUrl: String, url: String }

  connect() {
    const supported = typeof PublicKeyCredential !== "undefined" &&
      typeof PublicKeyCredential.parseCreationOptionsFromJSON === "function" &&
      typeof PublicKeyCredential.parseRequestOptionsFromJSON === "function"
    this.supportedTargets.forEach((element) => { element.hidden = !supported })
  }

  register(event) {
    event.preventDefault()
    const label = this.hasLabelTarget ? this.labelTarget.value : ""
    return this.run(
      (options) => navigator.credentials.create({ publicKey: PublicKeyCredential.parseCreationOptionsFromJSON(options) }),
      { label },
      () => window.location.reload()
    )
  }

  authenticate(event) {
    event.preventDefault()
    return this.run(
      (options) => navigator.credentials.get({ publicKey: PublicKeyCredential.parseRequestOptionsFromJSON(options) }),
      {},
      (response) => window.location.assign(response.redirect_to)
    )
  }

  async run(getCredential, extraParams, onSuccess) {
    this.errorTarget.hidden = true
    this.element.setAttribute("aria-busy", "true")
    try {
      const options = await this.post(this.optionsUrlValue)
      const credential = await getCredential(options)
      onSuccess(await this.post(this.urlValue, { credential: credential.toJSON(), ...extraParams }))
    } catch (error) {
      this.showError(error)
    } finally {
      this.element.removeAttribute("aria-busy")
    }
  }

  async post(url, body = {}) {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
      },
      body: JSON.stringify(body)
    })
    const text = await response.text()
    const data = text ? JSON.parse(text) : {}
    if (!response.ok) throw new Error(data.error || "Something went wrong. Please try again.")
    return data
  }

  showError(error) {
    this.errorTarget.textContent = this.messageFor(error)
    this.errorTarget.hidden = false
  }

  messageFor(error) {
    switch (error.name) {
      case "NotAllowedError": return "The passkey request was cancelled or timed out."
      case "InvalidStateError": return "A passkey for this account is already saved on this device."
      default: return error.message
    }
  }
}
