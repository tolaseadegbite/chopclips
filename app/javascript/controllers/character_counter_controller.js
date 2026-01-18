import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]

  connect() {
    this.update()
  }

  update() {
    const currentLength = this.inputTarget.value.length

    this.countTargets.forEach((target) => {
      target.textContent = currentLength
    })
  }
}