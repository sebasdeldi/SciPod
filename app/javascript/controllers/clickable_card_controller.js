import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.element.style.cursor = 'pointer'
  }

  click(event) {
    // Don't navigate if the click was on a button, form, or link
    if (this.isInteractiveElement(event.target)) {
      return
    }

    // Navigate to the podcast show page using Turbo for better performance
    Turbo.visit(this.urlValue)
  }

  isInteractiveElement(element) {
    // Check if the clicked element or any of its parents is interactive
    const interactiveSelectors = [
      'button',
      'a', 
      'form',
      '.favorite-button',
      '.play-button',
      '.favorite-form',
      '[type="submit"]',
      '[data-controller="audio-player"]' // Add this to ensure play buttons are recognized
    ]

    let currentElement = element
    while (currentElement && currentElement !== this.element) {
      for (const selector of interactiveSelectors) {
        if (currentElement.matches && currentElement.matches(selector)) {
          return true
        }
      }
      currentElement = currentElement.parentElement
    }

    return false
  }
} 