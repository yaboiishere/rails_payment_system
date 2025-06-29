module ApiSessionHelper
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def jwt_decode(token)
    { success?: true, token: JWT.decode(token, Rails.application.credentials.secret_key_base).first }
  rescue JWT::DecodeError => e
    { success?: false, error: e.message }
  end
end
