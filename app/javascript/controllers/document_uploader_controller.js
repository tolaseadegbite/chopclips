import { Controller } from "@hotwired/stimulus"
import Tesseract from "tesseract.js"

export default class extends Controller {
  static targets = ["input", "output", "spinner", "resultBridge", "payload"]

  connect() {
    this.streamId = this.element.dataset.streamId
    console.log("Document Uploader Connected") 
  }

  trigger() {
    this.inputTarget.click()
  }

  async upload(event) {
    const file = event.target.files[0]
    if (!file) return

    this.showLoading()

    if (file.type.startsWith("image/")) {
      await this.processImageLocally(file)
    } else {
      await this.uploadToServer(file)
    }

    this.inputTarget.value = ""
  }

  // STRATEGY A: Client-Side OCR
  async processImageLocally(file) {
    try {
      const result = await Tesseract.recognize(file, 'eng')
      
      // Clean the text before inserting
      const rawText = result.data.text
      const cleanText = this.cleanOCRText(rawText)
      
      this.insertText(cleanText)
    } catch (error) {
      console.error("OCR Error:", error)
      alert("Could not read text from this image.")
    } finally {
      this.hideLoading()
    }
  }

  // STRATEGY B: Server-Side Parsing
  async uploadToServer(file) {
    const formData = new FormData()
    formData.append("file", file)
    formData.append("stream_id", this.streamId)

    const token = document.querySelector('meta[name="csrf-token"]').content

    try {
      const response = await fetch("/document_extractions", {
        method: "POST",
        headers: { "X-CSRF-Token": token },
        body: formData
      })
      
      if (!response.ok) throw new Error("Server upload failed")
    } catch (error) {
      console.error("Upload Error:", error)
      this.hideLoading() // Hide spinner on HTTP error
    }
  }

  // --- BRIDGE: Turbo Stream Listener ---
  // Triggered automatically when the partial is injected by Turbo
  payloadTargetConnected(element) {
    const text = element.dataset.text
    // Check if the backend flagged this as an error (via data-error="true")
    const isError = element.dataset.error === "true"
    
    // 1. Always stop the spinner when ANY payload arrives
    this.hideLoading()
    
    // 2. Only logic if it is NOT an error
    // (If it IS an error, the Flash message handles the UI, we just stop spinning)
    if (!isError && text !== undefined) {
      if (text.trim().length > 0) {
        this.insertText(text)
      } else {
        // Fallback alert if text is empty but no specific error was raised
        // e.g. A PDF that is technically valid but contains only scanned images
        alert("No text found. This document might be a scanned image or empty.")
      }
    }
    
    // 3. Cleanup: Remove the element so it doesn't clutter the DOM
    element.remove()
  }

  // --- HELPERS ---

  // Helper: Fixes "unnecessary line breaks" from Tesseract
  cleanOCRText(text) {
    if (!text) return ""

    // 1. Split into paragraphs based on double newlines
    const paragraphs = text.split(/\n\s*\n/)

    return paragraphs
      .map(para => {
        // 2. Inside each paragraph, replace single newlines with a space
        return para
          .replace(/[\r\n]+/g, " ") // Turn newlines into spaces
          .replace(/\s+/g, " ")     // Squeeze multiple spaces into one
          .trim()
      })
      .filter(para => para.length > 0) // Remove empty paragraphs
      .join("\n\n") // Rejoin paragraphs with double spacing
  }

  insertText(text) {
    if (!this.hasOutputTarget) return
    this.outputTarget.value = text
    this.outputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    this.outputTarget.focus()
  }

  showLoading() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hide")
      this.spinnerTarget.classList.add("animate-spin")
    }
  }

  hideLoading() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("animate-spin")
      this.spinnerTarget.classList.add("hide")
    }
  }
}