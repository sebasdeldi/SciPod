##
# PodcastsController handles all podcast-related operations
#
# This controller manages the core functionality of the Podcast AI application:
# - CRUD operations for podcasts
# - Search functionality with instant results via Turbo
# - Favoriting/unfavoriting with real-time updates
# - File upload handling for PDFs and audio files
#
class PodcastsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show, :search ]
  before_action :set_podcast, only: [ :show, :edit, :update, :favorite, :unfavorite ]
  before_action :ensure_owner, only: [ :edit, :update ]

  ##
  # GET /podcasts
  # Display all podcasts with search functionality
  #
  def index
    @podcasts = Podcast.includes(:user, :authors, :publishers, :favorites)
                      .recent
                      .limit(20)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  ##
  # GET /podcasts/search
  # Search podcasts using pg_search with instant results
  #
  def search
    @query = params[:query]

    if @query.present?
      @podcasts = Podcast.search_by_content(@query)
                         .includes(:user, :authors, :publishers)
                         .limit(20)
    else
      # Show all podcasts when search is blank (same as index page)
      @podcasts = Podcast.includes(:user, :authors, :publishers, :favorites)
                         .recent
                         .limit(20)
    end

    respond_to do |format|
      format.turbo_stream { render :index }
      format.html { render :index }
    end
  end

  ##
  # GET /podcasts/1
  # Show individual podcast with audio player and details
  #
  def show
    @favorite = current_user&.favorites&.find_by(podcast: @podcast)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  ##
  # GET /podcasts/new
  # Form for creating a new podcast
  #
  def new
    @podcast = current_user.podcasts.build
  end

  ##
  # GET /podcasts/1/edit
  # Form for editing an existing podcast
  #
  def edit
    # AI-generated podcasts are not directly editable
    redirect_to @podcast, alert: 'AI-generated podcasts cannot be manually edited. Please create a new podcast if needed.'
  end
  ##
  # POST /podcasts
  # Create a new podcast with file uploads
  #
  def create
    @podcast = current_user.podcasts.build(podcast_params)

    # Set a temporary title that will be replaced by AI
    @podcast.title = "Processing: #{@podcast.source_file.filename}" if @podcast.source_file.attached?

    if @podcast.save
      # Auto-favorite the user's own podcast
      current_user.favorite!(@podcast) unless current_user.favorited?(@podcast)

      # TODO: Enqueue AI processing job here
      # PodcastProcessingJob.perform_later(@podcast)

      redirect_to @podcast, notice: 'Podcast uploaded successfully! AI processing has begun.'
    else
      render :new, status: :unprocessable_entity
    end
  end


  ##
  # PATCH/PUT /podcasts/1
  # Update an existing podcast
  #
  def update
    if @podcast.update(podcast_params)
      redirect_to @podcast, notice: 'Podcast was successfully updated.'
    else
      @authors = Author.all
      @publishers = Publisher.all
      render :edit, status: :unprocessable_entity
    end
  end

  ##
  # POST /podcasts/1/favorite
  # Add podcast to user's favorites via Turbo Stream
  #
  def favorite
    current_user.favorite!(@podcast)

    # Preserve search context for turbo stream updates
    @query = params[:query]
    if @query.present?
      @podcasts = Podcast.search_by_content(@query)
                         .includes(:user, :authors, :publishers)
                         .limit(20)
    else
      @podcasts = Podcast.includes(:user, :authors, :publishers, :favorites)
                         .recent
                         .limit(20)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @podcast }
    end
  end

  ##
  # DELETE /podcasts/1/unfavorite
  # Remove podcast from user's favorites via Turbo Stream
  #
  def unfavorite
    current_user.unfavorite!(@podcast)

    # Preserve search context for turbo stream updates
    @query = params[:query]
    if @query.present?
      @podcasts = Podcast.search_by_content(@query)
                         .includes(:user, :authors, :publishers)
                         .limit(20)
    else
      @podcasts = Podcast.includes(:user, :authors, :publishers, :favorites)
                         .recent
                         .limit(20)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @podcast }
    end
  end

  private

  ##
  # Find the podcast by ID
  #
  def set_podcast
    @podcast = Podcast.find(params[:id])
  end

  ##
  # Ensure current user owns the podcast (for edit/update)
  #
  def ensure_owner
    unless @podcast.user == current_user
      redirect_to podcasts_path, alert: 'You can only modify your own podcasts.'
    end
  end

  ##
  # Strong parameters for podcast creation/update
  #
  def podcast_params
    params.expect(
      podcast: [ :source_file ]
    )
  end
end
