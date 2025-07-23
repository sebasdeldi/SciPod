##
# PublishersController handles publisher management and autocomplete
#
# This controller provides functionality for:
# - Listing publishers for autocomplete
# - Creating new publishers dynamically
# - Showing publisher profiles and their podcasts
#
class PublishersController < ApplicationController
  before_action :set_publisher, only: [ :show ]

  ##
  # GET /publishers
  # List publishers with optional search for autocomplete
  #
  def index
    @publishers = if params[:search].present?
      Publisher.by_name(params[:search]).limit(10)
    else
      Publisher.limit(20)
    end

    respond_to do |format|
      format.html
      format.json { render json: @publishers.map { |p| { id: p.id, name: p.name } } }
      format.turbo_stream
    end
  end

  ##
  # GET /publishers/1
  # Show publisher profile and their associated podcasts
  #
  def show
    @podcasts = @publisher.podcasts.recent.includes(:user, :authors, :publishers)
  end

  ##
  # POST /publishers
  # Create a new publisher (for dynamic creation during podcast creation)
  #
  def create
    @publisher = Publisher.new(publisher_params)

    if @publisher.save
      respond_to do |format|
        format.json { render json: { id: @publisher.id, name: @publisher.name } }
        format.html { redirect_to @publisher, notice: 'Publisher was successfully created.' }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @publisher.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  ##
  # Find the publisher by ID
  #
  def set_publisher
    @publisher = Publisher.find(params[:id])
  end

  ##
  # Strong parameters for publisher creation
  #
  def publisher_params
    params.expect(publisher: [ :name ])
  end
end
