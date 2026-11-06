class PasskeysController < ApplicationController
  include PasskeyCeremony

  rescue_from Passkeys::Error, with: :render_passkey_error

  def options
    store_challenge(:passkey_registration_challenge, registration.options)
  end

  def create
    registration.register(credential: credential_param,
                          challenge: take_challenge(:passkey_registration_challenge),
                          label: params[:label].to_s.strip)
    head :created
  end

  def destroy
    current_user.passkeys.find(params.expect(:id)).destroy!
    redirect_to edit_user_registration_path, notice: t('.notice'), status: :see_other
  end

  private

  def registration
    Passkeys::Registration.new(user: current_user, relying_party: relying_party)
  end
end
