module Passkeys
  # Adds a passkey to a signed-in user: `options` starts the ceremony, `register` finishes it.
  class Registration
    def initialize(user:, relying_party:)
      @user = user
      @relying_party = relying_party
    end

    def options
      @relying_party.options_for_registration(
        user: { id: @user.ensure_webauthn_id!, name: @user.email, display_name: @user.first_name },
        exclude: @user.passkeys.pluck(:external_id),
        authenticator_selection: { resident_key: 'required', user_verification: 'required' }
      )
    end

    def register(credential:, challenge:, label:)
      raise Error, 'No registration in progress' if challenge.blank?

      verified = @relying_party.verify_registration(credential, challenge, user_verification: true)
      @user.passkeys.create!(
        external_id: verified.id,
        public_key: verified.public_key,
        sign_count: verified.sign_count,
        label: label.presence || "Passkey added #{Date.current.to_fs(:long)}"
      )
    rescue WebAuthn::Error, ActiveRecord::RecordInvalid => e
      raise Error, e.message
    end
  end
end
