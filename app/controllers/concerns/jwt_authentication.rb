# frozen_string_literal: true

module JwtAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_jwt
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_jwt, **options
    end
  end

  private

  def require_jwt
    token = request.headers["Authorization"].to_s.remove("Bearer ").presence
    return render json: { error: "Missing token" }, status: :unauthorized unless token

    payload = helpers.jwt_decode(token)
    if payload[:success?]
      token = payload[:token]
      user = User.find_by(id: token["payload"])
      if user.present?
        true
      else
        render json: { error: "Invalid session" }, status: :unauthorized
      end
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end
end
