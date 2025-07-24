##
# PodcastsController handles all podcast-related operations
#
# This controller manages the core functionality of the Podcast AI application:
# - Podcast creation and viewing (no editing - podcasts are immutable)
# - Search functionality with instant results via Turbo
# - Favoriting/unfavoriting with real-time updates
# - File upload handling for PDFs and audio files
#
class PodcastsController < ApplicationController
  before_action :authenticate_user!, except: [ :home, :discover, :show ]
  before_action :set_podcast, only: [ :show, :favorite, :unfavorite ]

  ##
  # GET /
  # Unified search and discovery homepage
  #
  def home
    @query = params[:query]

    if @query.present?
      @podcasts = Podcast.search_by_content(@query)
                         .includes(:user, :authors, :publishers)
                         .limit(20)
    else
      # Show all podcasts when search is blank (discovery mode)
      @podcasts = Podcast.includes(:user, :authors, :publishers, :favorites)
                         .recent
                         .limit(20)
    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  ##
  # GET /podcasts/discover - DEPRECATED: Redirects to home
  # Maintained for backward compatibility
  #
  def discover
    redirect_to root_path(params.permit(:query)), status: :moved_permanently
  end

  ##
  # GET /podcasts/1
  # Show individual podcast with audio player and details
  #
  def show
    @favorite = current_user&.favorites&.find_by(podcast: @podcast)

    respond_to do |format|
      format.html
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
  # POST /podcasts
  # Create a new podcast with file uploads
  #
  def create
    @podcast = current_user.podcasts.build(podcast_params)

    # Set a temporary title that will be replaced by AI
    @podcast.title = @podcast.source_file.filename if @podcast.source_file.attached?

    # Explicitly set initial processing status
    @podcast.status = :processing
    @podcast.status_details = "processing_source_file"

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
  # POST /podcasts/1/favorite
  # Add podcast to user's favorites via Turbo Stream
  #
  def favorite
    # Only process if not already favorited
    unless current_user.favorited?(@podcast)
      current_user.favorite!(@podcast)
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
    # Only process if currently favorited
    if current_user.favorited?(@podcast)
      current_user.unfavorite!(@podcast)
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
  # Strong parameters for podcast creation
  #
  def podcast_params
    params.expect(
      podcast: [ :source_file ]
    )
  end
end
