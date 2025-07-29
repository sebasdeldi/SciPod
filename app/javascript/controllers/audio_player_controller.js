import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, title: String, id: Number }

  playPodcast(event) {
    event.preventDefault()
    
    // Find the global audio player
    const globalPlayer = document.querySelector('[data-controller="global-audio-player"]')
    if (globalPlayer) {
      // Dispatch a custom event to the global player
      globalPlayer.dispatchEvent(new CustomEvent('play-podcast', {
        detail: {
          url: this.urlValue,
          title: this.titleValue,
          id: this.idValue,
          playButton: this.element
        }
      }))
    }
  }
} 