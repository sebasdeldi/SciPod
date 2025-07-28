import { Controller } from "@hotwired/stimulus"
import globalAudioManager from "./global_audio_manager"

export default class extends Controller {
  connect() {
    this.processedButtons = new Set() // Track which buttons we've already processed
    
    // Find all play buttons and add audio functionality
    this.setupPlayButtons()
    
    // Set up observer to watch for new podcast cards added via Turbo Stream
    this.setupMutationObserver()
    
    // Update buttons based on current global audio state
    this.updateButtonsFromGlobalState()
  }

  disconnect() {
    // Disconnect the mutation observer
    if (this.observer) {
      this.observer.disconnect()
    }
    // Note: We don't stop global audio on disconnect - it should persist!
  }

  setupMutationObserver() {
    // Watch for new podcast cards being added to the DOM
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          // Check if the added node contains podcast cards
          if (node.nodeType === Node.ELEMENT_NODE) {
            // If it's a podcast card itself
            if (node.classList?.contains('result-item')) {
              this.setupPlayButtonForCard(node)
            }
            // Or if it contains podcast cards
            const newCards = node.querySelectorAll?.('.result-item')
            newCards?.forEach(card => this.setupPlayButtonForCard(card))
          }
        })
      })
    })

    // Start observing
    this.observer.observe(this.element, {
      childList: true,
      subtree: true
    })
  }

  setupPlayButtons() {
    // Find all existing podcast cards
    const podcastCards = this.element.querySelectorAll('.result-item')
    podcastCards.forEach(card => this.setupPlayButtonForCard(card))
  }

  setupPlayButtonForCard(card) {
    const playButton = card.querySelector('.play-button')
    if (!playButton) return
    
    // Generate a unique identifier for this button to avoid double-processing
    const buttonId = `${card.querySelector('[id^="favorite_button_"]')?.id || ''}-play`
    if (this.processedButtons.has(buttonId)) return
    
    // Get podcast ID from the card
    const podcastId = this.extractPodcastId(card)
    if (!podcastId) return
    
    // Store original button content
    const originalIcon = playButton.querySelector('i')
    const originalIconClass = originalIcon ? originalIcon.className : ''
    
    // Replace the original click handler
    const newPlayButton = playButton.cloneNode(true)
    playButton.parentNode.replaceChild(newPlayButton, playButton)
    
    // Add our click handler
    newPlayButton.addEventListener('click', (event) => {
      event.preventDefault()
      event.stopPropagation()
      this.handlePlayClick(podcastId, card, newPlayButton, originalIcon, originalIconClass)
    })
    
    // Mark this button as processed
    this.processedButtons.add(buttonId)
    
    // Update button state based on global audio manager
    this.updateButtonState(podcastId, originalIcon, originalIconClass)
  }

  updateButtonsFromGlobalState() {
    // Update all buttons to reflect current global audio state
    setTimeout(() => {
      const podcastCards = this.element.querySelectorAll('.result-item')
      podcastCards.forEach(card => {
        const podcastId = this.extractPodcastId(card)
        const playButton = card.querySelector('.play-button i')
        if (podcastId && playButton) {
          this.updateButtonState(podcastId, playButton, 'fa-solid fa-play')
        }
      })
    }, 100)
  }

  updateButtonState(podcastId, iconElement, originalIconClass) {
    if (!iconElement) return
    
    const currentPodcast = globalAudioManager.getCurrentPodcast()
    
    if (currentPodcast?.id === podcastId) {
      if (globalAudioManager.isCurrentlyPlaying(podcastId)) {
        iconElement.className = "fa-solid fa-pause"
      } else {
        iconElement.className = "fa-solid fa-play"
      }
    } else {
      iconElement.className = originalIconClass || "fa-solid fa-play"
    }
  }

  extractPodcastId(card) {
    // Try to extract podcast ID from various sources
    const playButton = card.querySelector('.play-button')
    if (playButton && playButton.closest('form')) {
      const form = playButton.closest('form')
      const action = form.getAttribute('action')
      const match = action ? action.match(/\/podcasts\/(\d+)/) : null
      return match ? parseInt(match[1]) : null
    }
    
    // Try other methods to get podcast ID
    const favoriteButton = card.querySelector('[id^="favorite_button_"]')
    if (favoriteButton) {
      const match = favoriteButton.id.match(/favorite_button_(\d+)/)
      return match ? parseInt(match[1]) : null
    }
    
    return null
  }

  async handlePlayClick(podcastId, card, button, iconElement, originalIconClass) {
    const currentPodcast = globalAudioManager.getCurrentPodcast()
    
    if (currentPodcast?.id === podcastId) {
      // Toggle play/pause for current podcast
      if (globalAudioManager.isCurrentlyPlaying(podcastId)) {
        globalAudioManager.pause()
        iconElement.className = "fa-solid fa-play"
      } else {
        globalAudioManager.play()
        iconElement.className = "fa-solid fa-pause"
      }
    } else {
      // Play new podcast
      const audioUrl = await this.getAudioUrl(podcastId)
      if (audioUrl) {
        const title = card.querySelector('.result-title')?.textContent || 'Unknown Podcast'
        
        // Update previous podcast button
        this.updateButtonsFromGlobalState()
        
        // Start new podcast
        iconElement.className = "fa-solid fa-spinner fa-spin"
        await globalAudioManager.playPodcast(podcastId, audioUrl, title)
        iconElement.className = "fa-solid fa-pause"
      } else {
        // No audio available - use original navigation behavior
        window.location.href = `/podcasts/${podcastId}`
      }
    }
  }

  async getAudioUrl(podcastId) {
    try {
      // Get CSRF token
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
      
      const response = await fetch(`/podcasts/${podcastId}`, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'X-Scipod-Internal': 'true',
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin'
      })
      
      if (response.ok) {
        const data = await response.json()
        return data.audio_url
      } else if (response.status === 403) {
        console.error('Access forbidden - security check failed')
        return null
      }
    } catch (error) {
      console.error('Failed to get audio URL:', error)
    }
    
    return null
  }
} 