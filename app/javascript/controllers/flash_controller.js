import { Controller } from "@hotwired/stimulus"

/**
 * Flash Controller
 * 
 * Handles flash message behavior including auto-dismiss and
 * click-to-dismiss functionality.
 */
export default class extends Controller {
  static values = { 
    delay: { type: Number, default: 5000 }
  }

  connect() {
    // Auto-dismiss after delay
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.delayValue)

    // Add fade-in animation
    this.element.classList.add('flash-visible')
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  /**
   * Dismiss the flash message
   * Can be called automatically or by user click
   */
  dismiss() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Add fade-out animation
    this.element.classList.add('flash-dismissing')
    
    // Remove element after animation
    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.remove()
      }
    }, 300)
  }
} 