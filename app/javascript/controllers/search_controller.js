import { Controller } from "@hotwired/stimulus"

/**
 * Search Controller
 * 
 * Handles instant search functionality with debouncing to avoid
 * too many requests while the user is typing.
 */
export default class extends Controller {
  static targets = ["input", "button"]
  static values = { 
    delay: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
    this.updateButtonState()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  /**
   * Perform search with debouncing
   * Triggered on input events from the search field (for discover page only)
   */
  perform() {
    // Update button state on input change
    this.updateButtonState()
    
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Set new timeout for debounced search
    this.timeout = setTimeout(() => {
      this.executeSearch()
    }, this.delayValue)
  }

  /**
   * Execute the actual search by submitting the form
   */
  executeSearch() {
    const query = this.inputTarget.value.trim()
    
    // Only search if there's actual content or if clearing the search
    if (query.length >= 2 || query.length === 0) {
      this.submitForm()
    }
  }

  /**
   * Submit the form with browser compatibility
   */
  submitForm() {
    const form = this.element.querySelector('form')
    if (!form) return
    
    // Ensure the input value is properly set before submission
    const queryInput = form.querySelector('input[name="query"]')
    if (queryInput && this.hasInputTarget) {
      queryInput.value = this.inputTarget.value
    }
    
    if (form.requestSubmit) {
      // Modern browsers
      form.requestSubmit()
    } else {
      // Fallback for older browsers
      form.submit()
    }
  }

  /**
   * Handle immediate search on form submission
   */
  submit(event) {
    // Prevent submission if input is empty
    const query = this.inputTarget.value.trim()
    if (query.length === 0) {
      event.preventDefault()
      return false
    }
    
    // Let Turbo handle the form submission
    // This ensures proper Turbo Frame targeting
  }

  /**
   * Update button state based on input content
   * Can be called directly from input events or internally
   */
  updateButtonState() {
    if (this.hasButtonTarget) {
      const query = this.inputTarget.value.trim()
      this.buttonTarget.disabled = query.length === 0
    }
  }
} 