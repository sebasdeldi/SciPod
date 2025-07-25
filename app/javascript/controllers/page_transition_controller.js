import { Controller } from "@hotwired/stimulus"

// Page transition controller for smooth navigation animations
export default class extends Controller {
  static targets = ["content"]

  connect() {
    // Listen for Turbo navigation events
    document.addEventListener("turbo:click", this.handleClick.bind(this))
    document.addEventListener("turbo:before-render", this.handleBeforeRender.bind(this))
    document.addEventListener("turbo:render", this.handleRender.bind(this))
    
    // Initial page load animation
    this.animateIn()
  }

  disconnect() {
    document.removeEventListener("turbo:click", this.handleClick.bind(this))
    document.removeEventListener("turbo:before-render", this.handleBeforeRender.bind(this))
    document.removeEventListener("turbo:render", this.handleRender.bind(this))
  }

  handleClick(event) {
    // Only animate if it's a podcast link or major navigation
    const link = event.target.closest('a')
    if (link && (link.href.includes('/podcasts/') || link.classList.contains('result-link'))) {
      this.animateOut()
    }
  }

  handleBeforeRender(event) {
    // Prepare for new content
    this.element.classList.add("transitioning")
  }

  handleRender(event) {
    // New content is ready, animate in
    this.animateIn()
    this.element.classList.remove("transitioning")
  }

  animateOut() {
    this.element.classList.add("page-transition-out")
  }

  animateIn() {
    // Remove any existing transition classes
    this.element.classList.remove("page-transition-out")
    
    // Trigger animation
    this.element.classList.add("page-transition-in")
    
    // Clean up after animation
    setTimeout(() => {
      this.element.classList.remove("page-transition-in")
    }, 300)
  }
} 