import { Controller } from "@hotwired/stimulus"

/**
 * Podcast Form Controller
 * 
 * Handles form validation, file upload previews, and user feedback
 * for the podcast creation form.
 */
export default class extends Controller {
  static targets = [
    "sourceFile", "sourcePreview", "submitButton"
  ]

  connect() {
    this.maxSourceSize = 50 * 1024 * 1024 // 50MB
  }

  /**
   * Validate uploaded files and show previews
   */
  validateFile(event) {
    const input = event.target
    const file = input.files[0]
    
    if (!file) {
      this.clearPreview(input)
      return
    }

    // Only handle PDF files for source
    const maxSize = this.maxSourceSize
    const allowedTypes = ['application/pdf']

    // Validate file size
    if (file.size > maxSize) {
      this.showFileError(input, `File size must be less than ${this.formatFileSize(maxSize)}`)
      return
    }

    // Validate file type
    if (!allowedTypes.includes(file.type)) {
      this.showFileError(input, 'Invalid file type. Please upload a PDF.')
      return
    }

    // Show file preview
    this.showFilePreview(input, file)
  }

  /**
   * Show file preview with details
   */
  showFilePreview(input, file) {
    this.sourcePreviewTarget.innerHTML = `
      <div class="file-preview-item valid">
        <div class="file-icon">📄</div>
        <div class="file-details">
          <div class="file-name">${file.name}</div>
          <div class="file-size">${this.formatFileSize(file.size)}</div>
        </div>
        <div class="file-status">✓</div>
      </div>
    `
    
    // Clear any previous errors
    this.clearFileError(input)
  }

  /**
   * Show file error message
   */
  showFileError(input, message) {
    this.sourcePreviewTarget.innerHTML = `
      <div class="file-preview-item error">
        <div class="file-icon">❌</div>
        <div class="file-details">
          <div class="file-error">${message}</div>
        </div>
      </div>
    `
    
    // Clear the input
    input.value = ''
    
    // Add error styling to input
    input.classList.add('error')
  }

  /**
   * Clear file preview
   */
  clearPreview(input) {
    this.sourcePreviewTarget.innerHTML = ''
    this.clearFileError(input)
  }

  /**
   * Clear file error styling
   */
  clearFileError(input) {
    input.classList.remove('error')
  }

  /**
   * Format file size for display
   */
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  /**
   * Handle form submission
   */
  submit(event) {
    // Add loading state to submit button
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.textContent = 'Creating...'
    }
  }
} 