##
# AuthorsController handles author management and autocomplete
#
# This controller provides functionality for:
# - Listing authors for autocomplete
# - Creating new authors dynamically
# - Showing author profiles and their podcasts
#
class AuthorsController < ApplicationController
  before_action :set_author, only: [ :show ]

  ##
  # GET /authors
  # List authors with optional search for autocomplete
  #
  def index
    @authors = if params[:search].present?
                 Author.by_name(params[:search]).limit(10)
    else
                 Author.limit(20)
    end

    respond_to do |format|
      format.html
      format.json { render json: @authors.map { |a| { id: a.id, name: a.name } } }
      format.turbo_stream
    end
  end

  ##
  # GET /authors/1
  # Show author profile and their associated podcasts
  #
  def show
    @podcasts = @author.podcasts.recent.includes(:user, :authors, :publishers)
  end

  ##
  # POST /authors
  # Create a new author (for dynamic creation during podcast creation)
  #
  def create
    @author = Author.new(author_params)

    if @author.save
      respond_to do |format|
        format.json { render json: { id: @author.id, name: @author.name } }
        format.html { redirect_to @author, notice: 'Author was successfully created.' }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @author.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  ##
  # Find the author by ID
  #
  def set_author
    @author = Author.find(params[:id])
  end

  ##
  # Strong parameters for author creation
  #
  def author_params
    params.expect(author: [ :name ])
  end
end
