// Global Audio Manager - Persists across page navigation
class GlobalAudioManager {
  constructor() {
    this.currentAudio = null
    this.currentPodcast = null
    this.isPlaying = false
    this.playerElement = null
    this.isInitialized = false
    
    this.init()
  }

  init() {
    if (this.isInitialized) return
    
    // Create floating audio player UI
    this.createPlayerUI()
    
    // Listen for all types of navigation events
    this.setupNavigationListeners()
    
    this.isInitialized = true
  }

  setupNavigationListeners() {
    // Turbo navigation events
    document.addEventListener('turbo:before-cache', () => {
      this.preservePlayerForNavigation()
    })
    
    document.addEventListener('turbo:before-render', () => {
      this.preservePlayerForNavigation()
    })
    
    document.addEventListener('turbo:load', () => {
      this.restorePlayerAfterNavigation()
    })
    
    // Handle regular page navigation (fallback)
    window.addEventListener('beforeunload', () => {
      this.preservePlayerForNavigation()
    })
    
    window.addEventListener('pageshow', () => {
      this.restorePlayerAfterNavigation()
    })
    
    // Handle visibility changes
    document.addEventListener('visibilitychange', () => {
      if (!document.hidden) {
        this.ensurePlayerVisible()
      }
    })
  }

  createPlayerUI() {
    // Remove any existing player first
    const existingPlayer = document.getElementById('floating-audio-player')
    if (existingPlayer) {
      existingPlayer.remove()
    }
    
    // Create floating audio player
    this.playerElement = document.createElement('div')
    this.playerElement.id = 'floating-audio-player'
    this.playerElement.className = 'floating-audio-player hidden'
    
    // Mark as persistent element to avoid Turbo interference
    this.playerElement.setAttribute('data-turbo-permanent', '')
    
    this.playerElement.innerHTML = `
      <div class="player-content">
        <div class="player-info">
          <span class="player-title">Loading...</span>
        </div>
        <div class="player-controls">
          <button class="player-play-btn" title="Play/Pause">
            <i class="fa-solid fa-play"></i>
          </button>
          <button class="player-close-btn" title="Stop">
            <i class="fa-solid fa-times"></i>
          </button>
        </div>
      </div>
      <div class="player-progress">
        <div class="progress-bar">
          <div class="progress-fill"></div>
        </div>
        <div class="player-time">
          <span class="current-time">0:00</span>
          <span class="total-time">0:00</span>
        </div>
      </div>
    `
    
    // Append to body to avoid Turbo cache issues
    document.body.appendChild(this.playerElement)
    this.setupPlayerControls()
  }

  setupPlayerControls() {
    const playBtn = this.playerElement.querySelector('.player-play-btn')
    const closeBtn = this.playerElement.querySelector('.player-close-btn')
    
    playBtn.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      if (this.currentAudio) {
        if (this.currentAudio.paused) {
          this.play()
        } else {
          this.pause()
        }
      }
    })
    
    closeBtn.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.stop()
    })
  }

  async playPodcast(podcastId, audioUrl, title) {
    // Stop current audio if different podcast
    if (this.currentPodcast && this.currentPodcast.id !== podcastId) {
      this.stop()
    }
    
    // Create or reuse audio element
    if (!this.currentAudio || this.currentPodcast?.id !== podcastId) {
      if (this.currentAudio) {
        this.currentAudio.pause()
        this.currentAudio.src = ""
      }
      
      this.currentAudio = new Audio(audioUrl)
      this.currentPodcast = { id: podcastId, title, audioUrl }
      this.setupAudioEvents()
    }
    
    // Ensure player is visible and in DOM
    this.ensurePlayerVisible()
    this.showPlayer()
    this.updatePlayerInfo(title)
    
    // Play audio
    try {
      this.updatePlayButton('loading')
      await this.currentAudio.play()
      this.isPlaying = true
      this.updatePlayButton('playing')
    } catch (error) {
      console.error('Audio play failed:', error)
      this.updatePlayButton('error')
    }
  }

  setupAudioEvents() {
    if (!this.currentAudio) return
    
    this.currentAudio.addEventListener('loadstart', () => {
      this.updatePlayButton('loading')
    })
    
    this.currentAudio.addEventListener('canplay', () => {
      this.updatePlayerTime()
    })
    
    this.currentAudio.addEventListener('timeupdate', () => {
      this.updateProgress()
      this.updatePlayerTime()
    })
    
    this.currentAudio.addEventListener('ended', () => {
      this.stop()
    })
    
    this.currentAudio.addEventListener('error', () => {
      this.updatePlayButton('error')
    })
  }

  play() {
    if (this.currentAudio) {
      this.currentAudio.play()
      this.isPlaying = true
      this.updatePlayButton('playing')
      this.ensurePlayerVisible()
    }
  }

  pause() {
    if (this.currentAudio) {
      this.currentAudio.pause()
      this.isPlaying = false
      this.updatePlayButton('paused')
    }
  }

  stop() {
    if (this.currentAudio) {
      this.currentAudio.pause()
      this.currentAudio.currentTime = 0
      this.isPlaying = false
    }
    
    this.hidePlayer()
    this.currentPodcast = null
    
    // Update any page-specific play buttons
    this.updatePagePlayButtons()
  }

  showPlayer() {
    if (this.playerElement) {
      this.playerElement.classList.remove('hidden')
    }
  }

  hidePlayer() {
    if (this.playerElement) {
      this.playerElement.classList.add('hidden')
    }
  }

  ensurePlayerVisible() {
    // Make sure player element exists and is in the DOM
    if (!this.playerElement || !document.body.contains(this.playerElement)) {
      this.createPlayerUI()
    }
    
    // If we have a current podcast, make sure player is shown
    if (this.currentPodcast) {
      this.showPlayer()
      this.updatePlayerInfo(this.currentPodcast.title)
      
      if (this.isPlaying) {
        this.updatePlayButton('playing')
      } else {
        this.updatePlayButton('paused')
      }
    }
  }

  preservePlayerForNavigation() {
    // Store player state in sessionStorage for navigation persistence
    if (this.currentPodcast) {
      const playerState = {
        podcast: this.currentPodcast,
        isPlaying: this.isPlaying,
        currentTime: this.currentAudio ? this.currentAudio.currentTime : 0,
        playerVisible: !this.playerElement?.classList.contains('hidden')
      }
      sessionStorage.setItem('scipod_audio_state', JSON.stringify(playerState))
    }
  }

  restorePlayerAfterNavigation() {
    // Restore player state after navigation
    setTimeout(() => {
      this.ensurePlayerVisible()
      this.updatePagePlayButtons()
      
      // Restore from sessionStorage if needed
      const savedState = sessionStorage.getItem('scipod_audio_state')
      if (savedState && !this.currentPodcast) {
        try {
          const state = JSON.parse(savedState)
          if (state.playerVisible) {
            this.currentPodcast = state.podcast
            this.ensurePlayerVisible()
          }
        } catch (e) {
          console.warn('Failed to restore audio state:', e)
        }
      }
    }, 50)
  }

  updatePlayerInfo(title) {
    const titleElement = this.playerElement?.querySelector('.player-title')
    if (titleElement) {
      titleElement.textContent = title
    }
  }

  updatePlayButton(state) {
    const playBtn = this.playerElement?.querySelector('.player-play-btn i')
    if (!playBtn) return
    
    switch (state) {
      case 'loading':
        playBtn.className = "fa-solid fa-spinner fa-spin"
        break
      case 'playing':
        playBtn.className = "fa-solid fa-pause"
        break
      case 'paused':
        playBtn.className = "fa-solid fa-play"
        break
      case 'error':
        playBtn.className = "fa-solid fa-exclamation-triangle"
        break
    }
  }

  updateProgress() {
    if (!this.currentAudio) return
    
    const progressFill = this.playerElement?.querySelector('.progress-fill')
    if (progressFill && this.currentAudio.duration) {
      const progress = (this.currentAudio.currentTime / this.currentAudio.duration) * 100
      progressFill.style.width = `${progress}%`
    }
  }

  updatePlayerTime() {
    if (!this.currentAudio) return
    
    const currentTimeElement = this.playerElement?.querySelector('.current-time')
    const totalTimeElement = this.playerElement?.querySelector('.total-time')
    
    if (currentTimeElement) {
      currentTimeElement.textContent = this.formatTime(this.currentAudio.currentTime)
    }
    
    if (totalTimeElement && this.currentAudio.duration) {
      totalTimeElement.textContent = this.formatTime(this.currentAudio.duration)
    }
  }

  updatePagePlayButtons() {
    // Update play buttons on the current page to reflect audio state
    document.querySelectorAll('.result-item').forEach(card => {
      const podcastId = this.extractPodcastIdFromCard(card)
      const playButton = card.querySelector('.play-button i')
      
      if (playButton && podcastId) {
        if (this.currentPodcast?.id === podcastId) {
          if (this.isPlaying) {
            playButton.className = "fa-solid fa-pause"
          } else {
            playButton.className = "fa-solid fa-play"
          }
        } else {
          playButton.className = "fa-solid fa-play"
        }
      }
    })
  }

  extractPodcastIdFromCard(card) {
    const favoriteButton = card.querySelector('[id^="favorite_button_"]')
    if (favoriteButton) {
      const match = favoriteButton.id.match(/favorite_button_(\d+)/)
      return match ? parseInt(match[1]) : null
    }
    return null
  }

  formatTime(seconds) {
    if (!seconds || isNaN(seconds)) return "0:00"
    
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = Math.floor(seconds % 60)
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
  }

  // Public API for page controllers
  isCurrentlyPlaying(podcastId) {
    return this.currentPodcast?.id === podcastId && this.isPlaying
  }

  getCurrentPodcast() {
    return this.currentPodcast
  }
}

// Initialize global manager
if (!window.globalAudioManager) {
  window.globalAudioManager = new GlobalAudioManager()
}

export default window.globalAudioManager 