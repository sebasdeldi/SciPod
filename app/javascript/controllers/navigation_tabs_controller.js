import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation-tabs"
export default class extends Controller {
  static targets = ["form", "tabInput"]

  connect() {
    // Add event listener for Turbo events
    document.addEventListener('turbo:before-fetch-request', this.beforeFetch.bind(this))
    document.addEventListener('turbo:before-fetch-response', this.beforeResponse.bind(this))
    document.addEventListener('turbo:frame-render', this.afterRender.bind(this))
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener('turbo:before-fetch-request', this.beforeFetch.bind(this))
    document.removeEventListener('turbo:before-fetch-response', this.beforeResponse.bind(this))
    document.removeEventListener('turbo:frame-render', this.afterRender.bind(this))
  }

  switchTab(event) {
    const newTab = event.currentTarget.dataset.tab
    const currentTab = this.tabInputTarget.value

    // Don't do anything if clicking the same tab
    if (newTab === currentTab) {
      return
    }

    // Update active states immediately for visual feedback
    this.updateActiveStates(newTab)
    
    // Animate out content before submitting the form
    const searchResults = document.querySelector('.search-results-main')
    if (searchResults) {
      // Add animation class
      searchResults.style.transition = 'opacity 0.16s ease-out, transform 0.16s ease-out'
      searchResults.style.opacity = '0'
      searchResults.style.transform = 'translateY(10px)'
      
      // Wait for animation to complete before submitting
      setTimeout(() => {
        // Update the hidden input and submit the form
        this.tabInputTarget.value = newTab
        this.formTarget.requestSubmit()
      }, 160)
    } else {
      // No animation possible, just submit
      this.tabInputTarget.value = newTab
      this.formTarget.requestSubmit()
    }
  }

  beforeFetch(event) {
    // Animation is already in progress
  }

  beforeResponse(event) {
    // Prepare for new content
  }

  afterRender(event) {
    // Animate in the new content
    const searchResults = document.querySelector('.search-results-main')
    if (searchResults) {
      // Set initial state
      searchResults.style.transition = 'opacity 0.24s ease-in, transform 0.24s ease-out'
      searchResults.style.opacity = '0'
      searchResults.style.transform = 'translateY(-10px)'
      
      // Force reflow
      searchResults.offsetHeight
      
      // Animate in
      searchResults.style.opacity = '1'
      searchResults.style.transform = 'translateY(0)'
    }
  }

  updateActiveStates(activeTab) {
    // Remove active class from all tabs
    document.querySelectorAll('.nav-tab').forEach(tab => {
      tab.classList.remove('active')
    })

    // Add active class to the clicked tab
    document.querySelector(`[data-tab="${activeTab}"]`).classList.add('active')
  }


} 