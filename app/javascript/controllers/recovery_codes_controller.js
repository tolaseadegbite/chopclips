import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Add the new target to the list
  static targets = ["code", "copyButton", "copyButtonText"]

  copy() {
    const codesText = this.codeTargets.map(element => element.textContent.trim()).join("\n")
    
    navigator.clipboard.writeText(codesText).then(() => {
      // Get the original text from our new, specific target
      const originalText = this.copyButtonTextTarget.textContent
      
      // Only change the text, leaving the icon untouched
      this.copyButtonTextTarget.textContent = "Copied!"
      
      // Optionally, you might want to hide the icon while "Copied!" is shown
      // this.copyButtonTarget.querySelector('.icon').style.display = 'none';

      setTimeout(() => {
        // Restore the original text to our specific target
        this.copyButtonTextTarget.textContent = originalText
        // And show the icon again if you hid it
        // this.copyButtonTarget.querySelector('.icon').style.display = 'inline-block';
      }, 2000)
    })
  }

  // Action to download codes as a .txt file
  download() {
    // 1. Get the text from all code targets, just like in the copy action
    const codesText = this.codeTargets.map(element => element.textContent.trim()).join("\n")
    
    // 2. Add a helpful header for the text file
    const fileContent = "Your 2yarn Recovery Codes\n\n" +
                        "Keep these codes in a safe and accessible place.\n" +
                        "Each code can only be used once.\n\n" +
                        codesText

    // 3. Create a "Blob" - a file-like object in the browser's memory
    const blob = new Blob([fileContent], { type: "text/plain" })
    
    // 4. Create a temporary, invisible link element
    const link = document.createElement("a")
    link.href = URL.createObjectURL(blob)
    link.download = "yarnafrica-recovery-codes.txt" // The desired filename

    // 5. Simulate a click on the link to trigger the download, then clean up
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}