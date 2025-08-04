##
# FavoritesController handles AJAX favoriting operations
#
# This controller provides API endpoints for favoriting/unfavoriting podcasts
# using Turbo Stream for instant UI updates without page reloads.
#
class FavoritesController < ApplicationController
  before_action :set_podcast

  ##
  # POST /favorites
  # Create a new favorite relationship via AJAX
  #
  def create
    unless current_user.favorited?(@podcast)
      @favorite = current_user.favorite!(@podcast)
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "favorite_button_#{@podcast.id}",
          partial: "shared/favorite_button",
          locals: { podcast: @podcast, current_user: current_user }
        )
      end
      format.html { redirect_to @podcast }
      format.json { render json: { favorited: true } }
    end
  end

  ##
  # DELETE /favorites/1
  # Remove a favorite relationship via AJAX
  #
  def destroy
    if current_user.favorited?(@podcast)
      current_user.unfavorite!(@podcast)
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "favorite_button_#{@podcast.id}",
          partial: "shared/favorite_button",
          locals: { podcast: @podcast, current_user: current_user }
        )
      end
      format.html { redirect_to @podcast }
      format.json { render json: { favorited: false } }
    end
  end

  private

  ##
  # Find the podcast from the favorite_id or podcast_id parameter
  #
  def set_podcast
    if params[:favorite_id]
      favorite = Favorite.find(params[:favorite_id])
      @podcast = favorite.podcast
    else
      @podcast = Podcast.find(params[:podcast_id])
    end
  end
end
