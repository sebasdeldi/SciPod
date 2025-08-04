class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Require authentication for all routes (Devise controllers will skip this automatically)
  before_action :authenticate_user!

  # Include cursor pagination functionality
  include CursorPaginatable

  private

  ##
  # Override Devise's after_sign_in_path to redirect to home
  #
  def after_sign_in_path_for(resource)
    root_path
  end

  ##
  # Override Devise's after_sign_out_path to redirect to sign in
  #
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
