module Passkeys
  # Signs a user in with a discoverable passkey: `options` starts the ceremony (no email needed),
  # `authenticate` finishes it and returns the User that owns the asserted credential.
  class Authentication
    def initialize(relying_party:)
      @relying_party = relying_party
    end

    def options
      @relying_party.options_for_authentication(user_verification: 'required')
    end

    def authenticate(credential:, challenge:)
      raise Error, 'No sign in in progress' if challenge.blank?

      assertion, passkey = @relying_party.verify_authentication(credential, challenge, user_verification: true) do |asserted|
        Passkey.find_by!(external_id: asserted.id)
      end
      check_user_handle(assertion, passkey)
      passkey.update!(sign_count: assertion.sign_count, last_used_at: Time.current)
      passkey.user
    rescue WebAuthn::Error, ActiveRecord::RecordNotFound => e
      raise Error, e.message
    end

    private

    # Authenticators echo back the user handle they stored at registration; when present it
    # must belong to the account that owns the credential.
    def check_user_handle(assertion, passkey)
      return if assertion.user_handle.blank?
      return if ActiveSupport::SecurityUtils.secure_compare(assertion.user_handle, passkey.user.webauthn_id.to_s)

      raise Error, 'Passkey does not belong to this account'
    end
  end
end
