module ApiSessionHelper
  def jwt_encode(payload, options = {})
    expires_at = options[:expires_at] || 24.hours.from_now.to_i
    wrapped_payload = { payload: payload, expires_at: expires_at }
    JWT.encode(wrapped_payload, Rails.application.credentials.secret_key_base)
  end

  def jwt_decode(token)
    wrapped_payload = JWT.decode(token, Rails.application.credentials.secret_key_base).first
    if wrapped_payload["expires_at"].to_i <= Time.now.to_i
      { success?: false, error: "Token has expired" }
    else
      { success?: true, token: JWT.decode(token, Rails.application.credentials.secret_key_base).first }
    end
  rescue JWT::DecodeError => e
    { success?: false, error: e.message }
  end
end
