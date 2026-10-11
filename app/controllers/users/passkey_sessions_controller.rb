module Users
  class PasskeySessionsController < ApplicationController
    include PasskeyCeremony

    skip_before_action :authenticate_user!
    rescue_from Passkeys::Error, with: :render_passkey_error

    def options
      store_challenge(:passkey_authentication_challenge, authentication.options)
    end

    def create
      user = authentication.authenticate(credential: credential_param,
                                         challenge: take_challenge(:passkey_authentication_challenge))
      user.remember_me = true
      sign_in(:user, user)
      render json: { redirect_to: after_sign_in_path_for(user) }
    end

    private

    def authentication
      Passkeys::Authentication.new(relying_party: relying_party)
    end
  end
end
