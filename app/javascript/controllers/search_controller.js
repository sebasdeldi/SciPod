import { Controller } from "@hotwired/stimulus"

/**
 * Search Controller
 * 
 * Handles instant search functionality with debouncing to avoid
 * too many requests while the user is typing.
 */
export default class extends Controller {
  static targets = ["input"]
  static values = { 
    delay: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  /**
   * Perform search with debouncing
   * Triggered on input events from the search field
   */
  perform() {
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
      this.element.requestSubmit()
    }
  }

  /**
   * Handle immediate search on form submission
   */
  submit(event) {
    // Let Turbo handle the form submission
    // This ensures proper Turbo Frame targeting
  }
} 