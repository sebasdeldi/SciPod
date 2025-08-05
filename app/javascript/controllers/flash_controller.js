import { Controller } from "@hotwired/stimulus"

/**
 * Flash Controller
 * 
 * Handles flash message behavior including auto-dismiss and
 * click-to-dismiss functionality with smooth animations.
 */
export default class extends Controller {
  static values = { 
    duration: { type: Number, default: 5000 }
  }

  connect() {
    // Show the flash message with animation
    requestAnimationFrame(() => {
      this.element.classList.add('flash-visible')
    })

    // Auto-dismiss after duration
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.durationValue)
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

    // Add dismiss animation
    this.element.classList.remove('flash-visible')
    this.element.classList.add('flash-dismissing')
    
    // Remove element after animation completes
    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.remove()
      }
    }, 400) // Match the CSS transition duration
  }
} 