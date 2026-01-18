import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-filter"
export default class extends Controller {
  // Define the target element for this controller
  static targets = ["filters"]

  // Action to be called on button click
  toggle() {
    // Toggles the 'hidden' utility class on the filters target div
    this.filtersTarget.classList.toggle("hide")
  }
}