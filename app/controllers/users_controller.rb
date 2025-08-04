##
# UsersController handles user dashboard and profile pages
#
# This controller manages user-specific views including:
# - User profile/dashboard
#
class UsersController < ApplicationController
  before_action :set_user, only: [ :show ]

  ##
  # GET /users/1
  # Show user profile (public view)
  #
  def show
    @podcasts = @user.podcasts.recent.limit(10)
    @favorites_count = @user.favorites.count
    @podcasts_count = @user.podcasts.count
  end

  private

  ##
  # Find the user by ID
  #
  def set_user
    @user = User.find(params[:id])
  end
end
