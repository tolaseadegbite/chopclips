import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["color", "hex"]

  // Updates the text input when the color picker changes
  syncHex() {
    this.hexTarget.value = this.colorTarget.value
  }

  // Updates the color picker when the user types a hex code
  syncColor() {
    this.colorTarget.value = this.hexTarget.value
  }
}