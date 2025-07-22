##
# UsersController handles user dashboard and profile pages
#
# This controller manages user-specific views including:
# - User profile/dashboard
# - User's favorited podcasts
# - User's created podcasts
#
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show ]
  before_action :ensure_current_user, only: [ :favorites, :my_podcasts ]

  ##
  # GET /users/1
  # Show user profile (public view)
  #
  def show
    @podcasts = @user.podcasts.recent.limit(10)
    @favorites_count = @user.favorites.count
    @podcasts_count = @user.podcasts.count
  end

  ##
  # GET /users/1/favorites
  # Show current user's favorited podcasts
  #
  def favorites
    @podcasts = current_user.favorited_podcasts
                           .includes(:user, :authors, :publishers)
                           .recent

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  ##
  # GET /users/1/my_podcasts
  # Show current user's created podcasts
  #
  def my_podcasts
    @podcasts = current_user.podcasts
                           .includes(:authors, :publishers, :favorites)
                           .recent

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  ##
  # Find the user by ID
  #
  def set_user
    @user = User.find(params[:id])
  end

  ##
  # Ensure the current user is accessing their own private pages
  #
  def ensure_current_user
    unless params[:id].to_i == current_user.id
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
