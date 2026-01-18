import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 1. Add "swatch" to targets
  static targets = ["input", "label", "swatch"]

  select(event) {
    const id = event.params.id
    const name = event.params.name
    const gradientStart = event.params.gradientStart
    const gradientEnd = event.params.gradientEnd

    // 1. Update Hidden Input
    if (this.hasInputTarget) {
      this.inputTarget.value = id
    }

    // 2. Update Label
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = name
    }

    // 3. Update Swatch Gradient
    if (this.hasSwatchTarget && gradientStart && gradientEnd) {
      this.swatchTarget.style.setProperty("--gradient-start", gradientStart)
      this.swatchTarget.style.setProperty("--gradient-end", gradientEnd)
    }

    // 4. Close Modal
    window.dispatchEvent(new CustomEvent("dialog:close"))
  }

  playPreview(event) {
    event.stopPropagation()
  }
}