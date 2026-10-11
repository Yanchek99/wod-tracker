module Passkeys
  # Raised for any failed registration or sign-in so controllers have one thing to rescue,
  # whether the cause was a bad ceremony (WebAuthn::Error) or an unknown credential.
  class Error < StandardError; end
end
