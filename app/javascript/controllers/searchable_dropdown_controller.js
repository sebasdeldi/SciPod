import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="searchable-dropdown"
export default class extends Controller {
  static targets = [
    "trigger", 
    "content", 
    "selectedDisplay", 
    "placeholderText",
    "arrow", 
    "searchInput", 
    "options"
  ]

  connect() {
    // Close dropdown when clicking outside
    this.boundHandleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.boundHandleOutsideClick)
    
    // Listen for turbo frame updates to refresh badges
    this.boundHandleTurboFrameLoad = this.handleTurboFrameLoad.bind(this)
    document.addEventListener("turbo:frame-load", this.boundHandleTurboFrameLoad)
    
    // Initialize and update display
    this.initializeDisplay()
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleOutsideClick)
    document.removeEventListener("turbo:frame-load", this.boundHandleTurboFrameLoad)
  }

  handleTurboFrameLoad(event) {
    // Refresh display after turbo frame updates (like search results)
    setTimeout(() => {
      this.initializeDisplay()
    }, 100)
  }

  initializeDisplay() {
    // Initialize selected categories array from hidden fields
    this.selectedCategories = this.getSelectedCategoriesFromDOM()
    
    // Sync dropdown option states with selected categories
    this.syncDropdownStates()
    
    // Update display to show any pre-selected categories
    this.updateDisplay()
  }

  syncDropdownStates() {
    if (!this.hasOptionsTarget) return

    // Get all selected category IDs
    const selectedIds = this.selectedCategories.map(cat => cat.id)

    // Update dropdown option states
    const options = this.optionsTarget.querySelectorAll('.dropdown-option')
    options.forEach(option => {
      const categoryId = option.dataset.categoryId
      const checkbox = option.querySelector(".option-checkbox i")
      
      if (selectedIds.includes(categoryId)) {
        option.classList.add("selected")
        if (checkbox) {
          checkbox.className = "fa-solid fa-square-check"
        }
      } else {
        option.classList.remove("selected")
        if (checkbox) {
          checkbox.className = "fa-regular fa-square-check"
        }
      }
    })
  }



  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    const dropdownDiv = this.element.querySelector('.searchable-dropdown')
    if (dropdownDiv) {
      dropdownDiv.classList.add("open")
    }
    // Focus search input when opening (only if it exists)
    if (this.hasSearchInputTarget) {
      setTimeout(() => {
        this.searchInputTarget.focus()
      }, 100)
    }
  }

  close() {
    const dropdownDiv = this.element.querySelector('.searchable-dropdown')
    if (dropdownDiv) {
      dropdownDiv.classList.remove("open")
    }
    // Clear search when closing (only if search input exists)
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ""
      this.showAllOptions()
    }
  }

  get isOpen() {
    const dropdownDiv = this.element.querySelector('.searchable-dropdown')
    return dropdownDiv ? dropdownDiv.classList.contains("open") : false
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target) && this.isOpen) {
      this.close()
    }
  }

  filter(event) {
    if (!this.hasOptionsTarget) return

    const searchTerm = event.target.value.toLowerCase()
    const options = this.optionsTarget.querySelectorAll(".dropdown-option")

    options.forEach(option => {
      const text = option.textContent.toLowerCase()
      if (text.includes(searchTerm)) {
        option.style.display = "block"
      } else {
        option.style.display = "none"
      }
    })
  }

  showAllOptions() {
    if (this.hasOptionsTarget) {
      const options = this.optionsTarget.querySelectorAll(".dropdown-option")
      options.forEach(option => {
        option.style.display = "block"
      })
    }
  }

  toggleCategory(event) {
    event.preventDefault()
    event.stopPropagation()

    const option = event.currentTarget
    const categoryId = option.dataset.categoryId
    const categoryName = option.dataset.categoryName

    if (this.selectedCategories.some(cat => cat.id === categoryId)) {
      // Remove category
      this.removeCategory(event)
    } else {
      // Add category
      this.addCategory(categoryId, categoryName)
      option.classList.add("selected")
      // Update checkbox icon
      const checkbox = option.querySelector(".option-checkbox i")
      checkbox.className = "fa-solid fa-square-check"
    }

    this.updateDisplay()
    this.updateHiddenFields()
    this.submitForm()
  }

  addCategory(categoryId, categoryName) {
    if (!this.selectedCategories.some(cat => cat.id === categoryId)) {
      this.selectedCategories.push({ id: categoryId, name: categoryName })
    }
  }

  removeCategory(event) {
    event.preventDefault()
    event.stopPropagation()

    const categoryId = event.currentTarget.dataset.categoryId || 
                      event.currentTarget.closest('[data-category-id]').dataset.categoryId

    // Remove from selected categories
    this.selectedCategories = this.selectedCategories.filter(cat => cat.id !== categoryId)

    // Update option state (only if options target exists)
    if (this.hasOptionsTarget) {
      const option = this.optionsTarget.querySelector(`[data-category-id="${categoryId}"]`)
      if (option) {
        option.classList.remove("selected")
        // Update checkbox icon
        const checkbox = option.querySelector(".option-checkbox i")
        if (checkbox) {
          checkbox.className = "fa-regular fa-square-check"
        }
      }
    }

    this.updateDisplay()
    this.updateHiddenFields()
    this.submitForm()
  }

  clearAll(event) {
    event.preventDefault()
    event.stopPropagation()

    this.selectedCategories = []

    // Update all options (only if options target exists)
    if (this.hasOptionsTarget) {
      const options = this.optionsTarget.querySelectorAll(".dropdown-option")
      options.forEach(option => {
        option.classList.remove("selected")
        const checkbox = option.querySelector(".option-checkbox i")
        if (checkbox) {
          checkbox.className = "fa-regular fa-square-check"
        }
      })
    }

    this.updateDisplay()
    this.updateHiddenFields()
    this.submitForm()
  }

  getSelectedCategoriesFromDOM() {
    const hiddenInputs = document.querySelectorAll('.selected-category-input')
    const categories = []
    
    hiddenInputs.forEach(input => {
      const categoryId = input.value
      
      // Try to get category name from dropdown option first
      let categoryName = null
      if (this.hasOptionsTarget) {
        const optionElement = this.optionsTarget.querySelector(`[data-category-id="${categoryId}"]`)
        if (optionElement) {
          categoryName = optionElement.dataset.categoryName
        }
      }
      
      // If we couldn't get the name from dropdown, we'll add with just the ID
      // and the updateDisplay method can handle it
      if (categoryName) {
        categories.push({ id: categoryId, name: categoryName })
      } else {
        // Add with placeholder name - we'll fetch it when needed
        categories.push({ id: categoryId, name: `Category ${categoryId}` })
      }
    })
    
    return categories
  }

  updateDisplay() {
    if (!this.hasSelectedDisplayTarget) return

    const displayContainer = this.selectedDisplayTarget

    // Clear current chips
    const existingChips = displayContainer.querySelectorAll('.category-chip')
    existingChips.forEach(chip => chip.remove())

    // Add chips for selected categories
    this.selectedCategories.forEach(category => {
      const chip = document.createElement('span')
      chip.className = 'category-chip'
      chip.dataset.categoryId = category.id
      chip.innerHTML = `
        ${category.name}
        <button type="button" 
                class="chip-remove"
                data-action="click->searchable-dropdown#removeCategory"
                data-category-id="${category.id}">
          <i class="fa-solid fa-times"></i>
        </button>
      `
      displayContainer.appendChild(chip)
    })
  }

  updateHiddenFields() {
    const container = document.getElementById('selected-categories-container')
    
    // Clear existing hidden fields
    container.innerHTML = ''
    
    // Add hidden field for each selected category
    this.selectedCategories.forEach(category => {
      const hiddenField = document.createElement('input')
      hiddenField.type = 'hidden'
      hiddenField.name = 'category_ids[]'
      hiddenField.value = category.id
      hiddenField.className = 'selected-category-input'
      container.appendChild(hiddenField)
    })
  }

  submitForm() {
    const form = this.element.closest("form")
    if (form) {
      // Use Turbo to submit the form to avoid full page reload
      form.requestSubmit()
    }
  }
} 