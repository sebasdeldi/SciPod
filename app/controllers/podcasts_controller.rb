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
  before_action :authenticate_user!, except: [ :home, :show ]
  before_action :set_podcast, only: [ :show, :favorite, :unfavorite, :favorite_button ]

  ##
  # GET /
  # Unified search and discovery homepage with infinite scrolling
  #
  def home
    @query = params[:query]
    @category_ids = Array(params[:category_ids]).compact_blank
    @before_cursor = params[:before]

    # Build the base relation based on search and category filtering
    base_relation = if @category_ids.any? && @query.present?
      # Both categories and search: use subquery to avoid table alias conflicts
      # OR operation: podcasts in ANY of the selected categories
      category_podcast_ids = Podcast.joins(:categories)
                                    .where(categories: { id: @category_ids })
                                    .distinct
                                    .pluck(:id)
      # Get unique podcast IDs efficiently - pg_search creates duplicates via joins
      search_podcast_ids = unique_podcast_ids_from_search(
        Podcast.where(id: category_podcast_ids).search_by_content(@query)
      )
      Podcast.where(id: search_podcast_ids)
             .includes(:user, :authors, :publishers, :categories)
             .with_favorites_for_user(current_user)
             .distinct
    elsif @category_ids.any?
      # Only category filters: show all podcasts in ANY of the selected categories (OR operation)
      Podcast.joins(:categories)
             .where(categories: { id: @category_ids })
             .with_favorites_for_user(current_user)
             .distinct
    elsif @query.present?
      # Only search: get unique IDs efficiently - pg_search creates duplicates via joins
      search_podcast_ids = unique_podcast_ids_from_search(
        Podcast.search_by_content(@query)
      )
      Podcast.where(id: search_podcast_ids)
             .with_favorites_for_user(current_user)
             .distinct
    else
      # Neither: show recent podcasts (discovery mode)
      Podcast.with_favorites_for_user(current_user)
    end

    # Apply cursor pagination to the relation using ID for unique ordering
    @podcasts, @cursor = paginate_with_cursor(
      base_relation,
      items: 20,
      before: @before_cursor,
      by: :id,
      direction: :desc
    )

    # Preload associations for the paginated results to avoid N+1 queries
    # We do this separately because includes() conflicts with GROUP BY in with_favorites_for_user
    ActiveRecord::Associations::Preloader.new(
      records: @podcasts,
      associations: [:user, :authors, :publishers, :categories]
    ).call

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end



  ##
  # GET /podcasts/1
  # Show individual podcast with audio player and details
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

  ##
  # GET /podcasts/1/favorite_button
  # Return just the favorite button HTML for AJAX requests
  #
  def favorite_button
    respond_to do |format|
      format.html do
        render partial: 'shared/favorite_button',
               locals: { podcast: @podcast, current_user: current_user }
      end
    end
  end

  private

  ##
  # Extract unique podcast IDs from a search relation that may contain duplicates
  # 
  # pg_search creates complex joins that can result in duplicate records.
  # This method efficiently extracts unique IDs by limiting the query size
  # before loading into memory for deduplication.
  #
  # @param [ActiveRecord::Relation] search_relation - The pg_search relation
  # @return [Array<Integer>] Unique podcast IDs
  #
  def unique_podcast_ids_from_search(search_relation)
    # Limit to reasonable size before loading into memory
    # Most search results will be under 100 records anyway
    limited_results = search_relation.limit(500).to_a.uniq
    limited_results.map(&:id)
  end

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
