import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "title", "authors", "playPauseBtn", "playPauseIcon", "speedBtn", "speedText", "speedDropdown", "favoriteContainer", "progressBar", "progressContainer", "timeDisplay", "currentTime", "totalTime"]
  
  connect() {
    // Listen for play-podcast events from individual play buttons
    this.element.addEventListener('play-podcast', this.handlePlayPodcast.bind(this))
    
    // Listen for specific Turbo Stream events that update favorites
    document.addEventListener('turbo:before-stream-render', this.handleFavoriteUpdate.bind(this))
    
    // Store current podcast info
    this.currentPodcast = null
    this.currentPlayButton = null
    this.isPlaying = false
    
    // Initialize speed
    this.currentSpeed = 1
  }
  
  disconnect() {
    this.element.removeEventListener('play-podcast', this.handlePlayPodcast.bind(this))
    document.removeEventListener('turbo:before-stream-render', this.handleFavoriteUpdate.bind(this))
  }
  
  onTimeUpdate() {
    if (this.audioTarget.duration) {
      const progress = (this.audioTarget.currentTime / this.audioTarget.duration) * 100
      
      // Use requestAnimationFrame for smoother animation
      requestAnimationFrame(() => {
        this.progressBarTarget.style.width = `${progress}%`
      })
      
      // Update current time display
      this.updateCurrentTime()
    }
  }
  
  onAudioLoaded() {
    if (this.currentPlayButton) {
      this.updatePlayButtonState(this.currentPlayButton, 'loaded')
    }
    // Update total time when audio is loaded
    this.updateTotalTime()
  }
  
  seekTo(event) {
    if (this.audioTarget.duration) {
      const rect = this.progressContainerTarget.getBoundingClientRect()
      const clickX = event.clientX - rect.left
      const percentage = clickX / rect.width
      const newTime = percentage * this.audioTarget.duration
      
      // Temporarily disable transition for immediate seeking
      this.progressBarTarget.style.transition = 'none'
      this.audioTarget.currentTime = Math.max(0, Math.min(newTime, this.audioTarget.duration))
      
      // Re-enable smooth transition after a brief delay
      setTimeout(() => {
        this.progressBarTarget.style.transition = 'width 0.3s linear'
      }, 100)
    }
  }
  
  formatTime(seconds) {
    if (isNaN(seconds)) return '0:00'
    
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = Math.floor(seconds % 60)
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
  }
  
  updateCurrentTime() {
    const currentTime = this.formatTime(this.audioTarget.currentTime)
    this.currentTimeTarget.textContent = currentTime
  }
  
  updateTotalTime() {
    const totalTime = this.formatTime(this.audioTarget.duration)
    this.totalTimeTarget.textContent = totalTime
  }
  
  resetTimeDisplay() {
    this.currentTimeTarget.textContent = '0:00'
    this.totalTimeTarget.textContent = '0:00'
  }
  
  handlePlayPodcast(event) {
    const { url, title, id, playButton } = event.detail
    
    // If same podcast is already loaded, just toggle play/pause
    if (this.currentPodcast && this.currentPodcast.id === id) {
      this.togglePlayPause()
      return
    }
    
    // Load new podcast
    this.loadPodcast(url, title, id, playButton)
    this.showPlayer()
    this.play()
  }
  
  loadPodcast(url, title, id, playButton) {
    // Update current podcast info
    this.currentPodcast = { url, title, id }
    this.currentPlayButton = playButton
    
    // Update UI
    this.titleTarget.textContent = title
    this.audioTarget.src = url
    this.audioTarget.playbackRate = this.currentSpeed
    
    // Reset progress line for new track (disable transition for instant reset)
    this.progressBarTarget.style.transition = 'none'
    this.progressBarTarget.style.width = '0%'
    
    // Reset time display
    this.resetTimeDisplay()
    
    // Re-enable smooth transition
    setTimeout(() => {
      this.progressBarTarget.style.transition = 'width 0.3s linear'
    }, 50)
    
    // Load authors information
    this.loadAuthorsInfo(id)
    
    // Load favorite button for this podcast
    this.loadFavoriteButton(id)
    
    // Reset all play buttons to play state
    this.resetAllPlayButtons()
    
    // Set current button to loading state
    this.updatePlayButtonState(playButton, 'loading')
    
    // Start title marquee if needed
    this.initTitleMarquee()
    this.initAuthorsMarquee()
  }
  
  loadAuthorsInfo(podcastId) {
    // Fetch authors from the card that triggered this player
    const podcastCard = document.querySelector(`[data-clickable-card-url-value*="podcasts/${podcastId}"]`)
    if (podcastCard) {
      const authorsElement = podcastCard.querySelector('.result-authors')
      if (authorsElement) {
        // Extract just the authors text (remove "Authors: " prefix)
        const authorsText = authorsElement.textContent.replace(/^Authors:\s*/, '')
        this.authorsTarget.textContent = authorsText
      } else {
        this.authorsTarget.textContent = ''
      }
    } else {
      this.authorsTarget.textContent = ''
    }
  }
  
  loadFavoriteButton(podcastId) {
    // Only load if user is signed in (check for body data attribute)
    if (!document.body.dataset.userSignedIn || document.body.dataset.userSignedIn !== 'true') {
      this.favoriteContainerTarget.innerHTML = ''
      return
    }
    
    // Fetch the favorite button HTML for this specific podcast
    fetch(`/podcasts/${podcastId}/favorite_button`, {
      method: 'GET',
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      this.favoriteContainerTarget.innerHTML = html
      // Update button styles to match player design
      this.styleFavoriteButton()
      // The fade-in will be handled by CSS when player gets "showing" class
    })
    .catch(error => {
      console.log('Could not load favorite button:', error)
      this.favoriteContainerTarget.innerHTML = ''
    })
  }
  
  styleFavoriteButton() {
    const favoriteBtn = this.favoriteContainerTarget.querySelector('.favorite-button')
    if (favoriteBtn) {
      // Apply player-specific styles
      favoriteBtn.classList.add('player-favorite-btn')
    }
  }
  
  showPlayer() {
    // Make player visible but keep it hidden above viewport
    this.element.style.display = 'flex'
    
    // Force a reflow to ensure the display change is applied
    this.element.offsetHeight
    
    // Small delay to ensure smooth animation start
    requestAnimationFrame(() => {
      this.element.classList.add('showing')
      this.element.classList.remove('hiding')
    })
    
    // Add padding to body with smooth transition and class for search header
    // Use responsive height: 80px for desktop/tablet, 70px for mobile
    const playerHeight = window.innerWidth <= 480 ? '70px' : '80px'
    document.body.style.paddingTop = playerHeight
    document.body.classList.add('audio-player-visible')
  }
  
  hidePlayer() {
    // Close speed dropdown if open
    this.speedDropdownTarget.style.display = 'none'
    
    // Add hiding class to trigger slide-out animation
    this.element.classList.add('hiding')
    this.element.classList.remove('showing')
    
    // Remove padding from body and class
    document.body.style.paddingTop = '0'
    document.body.classList.remove('audio-player-visible')
    
    // Hide the element after animation completes
    setTimeout(() => {
      if (this.element.classList.contains('hiding')) {
        this.element.style.display = 'none'
        this.element.classList.remove('hiding')
      }
    }, 400) // Match CSS transition duration
  }
  
  play() {
    if (this.audioTarget.src) {
      this.audioTarget.play()
        .then(() => {
          this.isPlaying = true
          this.updatePlayPauseButton('pause')
          this.updatePlayButtonState(this.currentPlayButton, 'playing')
        })
        .catch(error => {
          console.error('Error playing audio:', error)
          this.updatePlayButtonState(this.currentPlayButton, 'error')
        })
    }
  }
  
  pause() {
    this.audioTarget.pause()
    this.isPlaying = false
    this.updatePlayPauseButton('play')
    this.updatePlayButtonState(this.currentPlayButton, 'paused')
  }
  
  togglePlayPause() {
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
  }
  
  setSpeed(event) {
    const speed = parseFloat(event.target.dataset.speed)
    this.currentSpeed = speed
    this.audioTarget.playbackRate = speed
    this.speedTextTarget.textContent = `${speed}x`
    
    // Close dropdown
    this.speedDropdownTarget.style.display = 'none'
  }
  
  toggleSpeedDropdown() {
    const dropdown = this.speedDropdownTarget
    if (dropdown.style.display === 'block') {
      dropdown.style.display = 'none'
    } else {
      dropdown.style.display = 'block'
    }
  }
  
  close() {
    this.pause()
    this.hidePlayer()
    this.resetAllPlayButtons()
    this.currentPodcast = null
    this.currentPlayButton = null
    
    // Clear content
    this.authorsTarget.textContent = ''
    
    // Reset progress line (disable transition for instant reset)
    this.progressBarTarget.style.transition = 'none'
    this.progressBarTarget.style.width = '0%'
    
    // Reset time display
    this.resetTimeDisplay()
    
    // Clear favorite button after animation completes (matches hidePlayer timing)
    setTimeout(() => {
      this.favoriteContainerTarget.innerHTML = ''
    }, 400) // Match CSS transition duration
  }
  
  onAudioEnded() {
    this.isPlaying = false
    this.updatePlayPauseButton('play')
    this.updatePlayButtonState(this.currentPlayButton, 'ended')
  }
  
  updatePlayPauseButton(state) {
    const icon = this.playPauseIconTarget
    if (state === 'play') {
      icon.className = 'fa-solid fa-play'
    } else if (state === 'pause') {
      icon.className = 'fa-solid fa-pause'
    }
  }
  
  updatePlayButtonState(button, state) {
    if (!button) return
    
    const icon = button.querySelector('i')
    if (!icon) return
    
    switch (state) {
      case 'loading':
        icon.className = 'fa-solid fa-spinner fa-spin'
        break
      case 'loaded':
      case 'paused':
      case 'ended':
        icon.className = 'fa-solid fa-play'
        break
      case 'playing':
        icon.className = 'fa-solid fa-pause'
        break
      case 'error':
        icon.className = 'fa-solid fa-exclamation-triangle'
        break
    }
  }
  
  resetAllPlayButtons() {
    document.querySelectorAll('.play-button:not(.disabled)').forEach(button => {
      const icon = button.querySelector('i')
      if (icon) {
        icon.className = 'fa-solid fa-play'
      }
    })
  }
  
  initTitleMarquee() {
    const titleContainer = this.titleTarget.parentElement
    const title = this.titleTarget
    
    // Reset any existing animation smoothly
    title.style.transition = 'none'
    title.style.animation = 'none'
    title.style.transform = 'translate3d(0, 0, 0)'
    title.innerHTML = title.textContent // Reset to original text
    
    // Force a reflow to ensure styles are applied
    title.offsetHeight
    
    // Wait a bit for layout to settle, then check overflow
    setTimeout(() => {
      const containerWidth = titleContainer.clientWidth
      const titleWidth = title.scrollWidth
      
      // Check if title overflows (with small buffer for accuracy)
      if (titleWidth > containerWidth + 10) {
        // Duplicate the text for continuous loop with separator
        const originalText = title.textContent
        const separator = '&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;&nbsp;'
        title.innerHTML = `${originalText}${separator}${originalText}${separator}`
        
        // Force another reflow after text duplication
        title.offsetHeight
        
        // Calculate duration for seamless loop
        const newWidth = title.scrollWidth
        const singleTextWidth = (newWidth / 2) // Since we have 2 copies
        const pixelsPerSecond = 26
        const duration = singleTextWidth / pixelsPerSecond
        
        // Ensure smooth animation start
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            title.style.animation = `marquee ${duration}s linear infinite`
            title.style.animationDelay = '1s'
          })
        })
      }
    }, 200) // Same delay to ensure layout is stable
  }

  initAuthorsMarquee() {
    const authorsContainer = this.authorsTarget.parentElement
    const authors = this.authorsTarget
    
    // Skip if no authors text
    if (!authors.textContent.trim()) {
      return
    }
    
    // Reset any existing animation smoothly
    authors.style.transition = 'none'
    authors.style.animation = 'none'
    authors.style.transform = 'translate3d(0, 0, 0)'
    authors.innerHTML = authors.textContent // Reset to original text
    
    // Force a reflow to ensure styles are applied
    authors.offsetHeight
    
    // Wait a bit for layout to settle, then check overflow
    setTimeout(() => {
      const containerWidth = authorsContainer.clientWidth
      const authorsWidth = authors.scrollWidth
      
      // Check if authors overflows (with small buffer for accuracy)
      if (authorsWidth > containerWidth + 10) {
        // Duplicate the text for continuous loop with separator
        const originalText = authors.textContent
        const separator = '&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;&nbsp;'
        authors.innerHTML = `${originalText}${separator}${originalText}${separator}`
        
        // Force another reflow after text duplication
        authors.offsetHeight
        
        // Calculate duration for seamless loop
        const newWidth = authors.scrollWidth
        const singleTextWidth = (newWidth / 2) // Since we have 2 copies
        const pixelsPerSecond = 26
        const duration = singleTextWidth / pixelsPerSecond
        
        // Ensure smooth animation start
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            authors.style.animation = `marquee ${duration}s linear infinite`
            authors.style.animationDelay = '1s'
          })
        })
      }
    }, 200) // Same delay as title
  }

  handleFavoriteUpdate(event) {
    // Only proceed if we have a current podcast and this is a Turbo Stream replace
    if (!this.currentPodcast || !event.detail.newStream) {
      return
    }
    
    const streamContent = event.detail.newStream.innerHTML
    const podcastId = this.currentPodcast.id
    
    // Only update if this is specifically a favorite button replacement for our current podcast
    if (streamContent.includes(`favorite_button_${podcastId}`) && 
        streamContent.includes('favorite-button') &&
        (streamContent.includes('favorited') || streamContent.includes('not-favorited'))) {
      
      // Small delay to let the card update complete first
      setTimeout(() => {
        // Only reload if we still have the same podcast
        if (this.currentPodcast && this.currentPodcast.id === podcastId) {
          this.loadFavoriteButton(podcastId)
        }
      }, 50) // Smaller delay to be more responsive
    }
  }
} 