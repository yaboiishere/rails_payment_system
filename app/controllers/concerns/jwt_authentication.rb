# frozen_string_literal: true

module JwtAuthentication
  extend ActiveSupport::Concern
  include ApiSessionHelper

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

    payload = jwt_decode(token)
    if payload[:success?]
      token = payload[:token]
      @current_user = User.find_by(id: token["payload"])
      if @current_user.present?
        true
      else
        render json: { error: "Invalid session" }, status: :unauthorized
      end
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def verify_merchant(merchant_id)
    unless current_user.id.to_s == merchant_id.to_s
      render json: { error: "Unauthorized access" }, status: :forbidden
      return false
    end
    true
  end
end
