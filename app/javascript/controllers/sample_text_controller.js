import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 1. ADD "samples" to the targets list
  static targets = ["input", "resetButton", "samples"]

  connect() {
    this.handleInput()
  }

  handleInput() {
    const hasText = this.inputTarget.value.length > 0
    
    // Toggle Reset Button
    if (this.hasResetButtonTarget) {
      this.resetButtonTarget.hidden = !hasText
    }

    // 2. ADD THIS LOGIC BACK: Toggle Sample Texts
    // If text exists -> Hide samples. If empty -> Show samples.
    if (this.hasSamplesTarget) {
      this.samplesTarget.hidden = hasText
    }
  }

  resetForm() {
    this.inputTarget.value = ""
    this.handleInput() // This will now re-show the samples
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    this.inputTarget.focus()
  }

  insert(event) {
    this.inputTarget.value = event.params.text
    this.handleInput() // This will now hide the samples
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }

  showPlaceholder(event) {
    this.originalPlaceholder = this.inputTarget.placeholder
    this.inputTarget.placeholder = event.params.text
  }

  hidePlaceholder() {
    this.inputTarget.placeholder = this.originalPlaceholder || ""
  }
}