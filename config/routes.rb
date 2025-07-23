require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Devise routes for user authentication
  devise_for :users

  # Root route - will be the main podcast discovery page
  root "podcasts#index"

  # Podcast routes
  resources :podcasts, except: [ :destroy ] do
    member do
      post :favorite
      delete :unfavorite
    end

    collection do
      get :search
    end
  end

  # User dashboard and favorites
  resources :users, only: [ :show ] do
    member do
      get :favorites
      get :my_podcasts
    end
  end

  # Favorites routes (for AJAX operations)
  resources :favorites, only: [ :create, :destroy ]

  # Authors and Publishers (for autocomplete and management)
  resources :authors, only: [ :index, :show, :create ]
  resources :publishers, only: [ :index, :show, :create ]

  # Sidekiq Web UI (mount in development/staging, secure in production)
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors like Pingdom, Nagios, etc.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Direct uploads for Active Storage (used by file uploads)
  # Rails 8 handles these automatically
end
