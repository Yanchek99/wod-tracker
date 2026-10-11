# Shared plumbing for the WebAuthn ceremonies: a relying party scoped to the request's host
# (production, staging and PR environments each have their own, and a passkey is bound to the
# host it was created on) and single-use challenges held in the session.
module PasskeyCeremony
  extend ActiveSupport::Concern

  private

  def relying_party
    WebAuthn::RelyingParty.new(id: request.host, allowed_origins: [request.base_url], name: 'WOD Tracker')
  end

  def store_challenge(key, options)
    session[key] = options.challenge
    render json: options
  end

  def take_challenge(key)
    session.delete(key)
  end

  def credential_param
    params.permit(credential: {}).fetch(:credential, {}).to_h
  end

  def render_passkey_error(error)
    render json: { error: error.message }, status: :unprocessable_content
  end
end
