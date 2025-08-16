class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_update_path_for(resource)
    user_path(resource)
  end
end 