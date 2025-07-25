import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bottom-navigation"
export default class extends Controller {
  static targets = ["link"]

  connect() {
    // Controller is connected
  }

  preventActiveNavigation(event) {
    const clickedLink = event.currentTarget
    const activeItem = clickedLink.closest('li')
    
    // Check if the clicked item has the 'active' class
    if (activeItem && activeItem.classList.contains('active')) {
      // Prevent the default navigation behavior
      event.preventDefault()
      return false
    }
  }
} 