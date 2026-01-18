import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sound-effects-prompt-filler"
export default class extends Controller {
  static targets = [ "output" ]

  connect() {
    this.originalPlaceholder = this.outputTarget.placeholder
  }

  // --- ACTIONS ---
  insert(event) {
    const textToInsert = event.params.text
    this.outputTarget.value = textToInsert
    this.outputTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }

  // --- HOVER LOGIC ---
  showPlaceholder(event) {
    this.outputTarget.placeholder = event.params.text
  }

  hidePlaceholder() {
    this.outputTarget.placeholder = this.originalPlaceholder
  }
}