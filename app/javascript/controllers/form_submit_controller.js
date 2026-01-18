import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-submit"
export default class extends Controller {
  static targets = ["button", "spinner", "label"]

  // This method is called when the form begins its submission
  disable(event) {
    this.buttonTarget.disabled = true;
    this.spinnerTarget.classList.remove("hide"); // Assuming 'hide' is your class for display:none
    this.labelTarget.classList.add("hide");
  }

  // This method is called when the Turbo Stream response is received (success or failure)
  enable(event) {
    // A small delay can make the UX feel smoother
    setTimeout(() => {
      this.buttonTarget.disabled = false;
      this.spinnerTarget.classList.add("hide");
      this.labelTarget.classList.remove("hide");
    }, 200);
  }
}