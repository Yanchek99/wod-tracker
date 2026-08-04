module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def update_resource(resource, params)
      if params[:password].present? || (params[:email].present? && params[:email].to_s != resource.email)
        resource.update_with_password(params)
      else
        resource.update_without_password(params.except(:password, :password_confirmation, :current_password))
      end
    end

    def after_update_path_for(_resource)
      edit_registration_path(resource_name)
    end
  end
end
