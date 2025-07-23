import { Controller } from "@hotwired/stimulus"

/**
 * Modal Controller
 * 
 * Handles opening and closing modal dialogs, particularly for search results.
 * Provides backdrop clicking to close and prevents event propagation on content clicks.
 */
export default class extends Controller {
  static targets = ["container"]

  connect() {
    // Bind escape key to close modal
    this.boundEscapeHandler = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundEscapeHandler)
    
    // Bind popstate to handle back/forward navigation
    this.boundPopstateHandler = this.handlePopstate.bind(this)
    window.addEventListener("popstate", this.boundPopstateHandler)
    
    // Check if we should restore modal state on page load
    this.checkForSearchState()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundEscapeHandler)
    window.removeEventListener("popstate", this.boundPopstateHandler)
  }

  /**
   * Open the modal
   * Can be triggered manually or via form submission
   */
  open(event) {
    // Clear any existing content first
    this.clearContent()
    
    this.containerTarget.classList.add("modal-open")
    document.body.classList.add("modal-open")
    
    // Push search state to browser history if this is a form submission
    if (event && event.target) {
      const formData = new FormData(event.target)
      const query = formData.get('query')
      if (query) {
        this.pushSearchState(query)
      }
    }
    
    // Focus trap - focus the close button
    const closeButton = this.containerTarget.querySelector(".search-modal-close")
    if (closeButton) {
      closeButton.focus()
    }
  }

  /**
   * Clear modal content immediately
   */
  clearContent() {
    const modalBody = document.getElementById("search-modal-body")
    if (modalBody) {
      // Force clear any cached content and add loading immediately
      modalBody.innerHTML = '<div class="loading-content">Searching...</div>'
    }
  }

  /**
   * Close the modal
   */
  close(fromPopstate = false) {
    this.containerTarget.classList.remove("modal-open")
    document.body.classList.remove("modal-open")
    
    // Update URL but keep search input value (only if we're not handling a popstate)
    if (!fromPopstate) {
      const url = new URL(window.location)
      if (url.searchParams.has('search')) {
        url.searchParams.delete('search')
        window.history.pushState({}, '', url)
      }
      
      // Keep search input value - don't clear it
      // This allows users to quickly search again or refine their search
    }
    
    // Clear modal content after animation
    setTimeout(() => {
      const modalBody = document.getElementById("search-modal-body")
      if (modalBody && !this.containerTarget.classList.contains("modal-open")) {
        modalBody.innerHTML = ""
      }
    }, 300)
  }

  /**
   * Close modal when clicking on backdrop
   */
  closeOnBackdrop(event) {
    if (event.target === this.containerTarget) {
      this.close()
    }
  }

  /**
   * Prevent modal from closing when clicking on content
   */
  preventClose(event) {
    event.stopPropagation()
  }

  /**
   * Handle escape key to close modal
   */
  handleEscape(event) {
    if (event.key === "Escape" && this.containerTarget.classList.contains("modal-open")) {
      this.close()
    }
  }

  /**
   * Push search state to browser history
   */
  pushSearchState(query) {
    const url = new URL(window.location)
    url.searchParams.set('search', query)
    window.history.pushState({ search: query, modalOpen: true }, '', url)
  }

  /**
   * Handle browser back/forward navigation
   */
  handlePopstate(event) {
    if (event.state && event.state.modalOpen && event.state.search) {
      // Restore modal with search results
      this.restoreSearchModal(event.state.search)
    } else {
      // Close modal if no search state (pass true to indicate this is from popstate)
      if (this.containerTarget.classList.contains("modal-open")) {
        this.close(true)
      }
    }
  }

  /**
   * Check URL for search parameters on page load
   */
  checkForSearchState() {
    const urlParams = new URLSearchParams(window.location.search)
    const searchQuery = urlParams.get('search')
    
    if (searchQuery) {
      // Restore modal with search results
      this.restoreSearchModal(searchQuery)
    } else {
      // Set initial history state for homepage
      window.history.replaceState({}, '', window.location.pathname)
    }
  }

  /**
   * Restore modal with search results
   */
  restoreSearchModal(query) {
    // Set the search input value
    const searchInput = document.querySelector('[data-search-target="input"]')
    if (searchInput) {
      searchInput.value = query
    }
    
    // Open modal first
    this.containerTarget.classList.add("modal-open")
    document.body.classList.add("modal-open")
    
    // Submit search form to get results by programmatically submitting the form
    const searchForm = document.querySelector('.homepage-search-form')
    if (searchForm) {
      // Set the query value in a hidden field or the existing field
      const queryInput = searchForm.querySelector('input[name="query"]')
      if (queryInput) {
        queryInput.value = query
      }
      
      // Submit the form programmatically (this will trigger Turbo Stream response)
      searchForm.requestSubmit()
    }
  }
} 