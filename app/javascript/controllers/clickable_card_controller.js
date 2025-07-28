import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  click(event) {
    // Don't navigate if clicking on play button or its children
    if (event.target.closest('.play-button')) {
      event.stopPropagation()
      return
    }
    
    // Don't navigate if clicking on favorite button or its children
    if (event.target.closest('.result-favorite')) {
      event.stopPropagation()
      return
    }

    // Navigate to the podcast page
    if (this.urlValue) {
      window.location.href = this.urlValue
    }
  }
} 