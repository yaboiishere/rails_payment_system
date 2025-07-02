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
    unless token
      render_response(success: false, errors: { error: "Missing token" }, error_status: :unauthorized)
      return false
    end

    payload = jwt_decode(token)
    if payload[:success?]
      user_id = payload[:token]
      @current_user = User.find_by(id: user_id)
      unless @current_user
        render_response(success: false, errors: { error: "Invalid session" }, error_status: :unauthorized)
        return false
      end
      true
    else
      render_response(success: false, errors: { error: "Invalid token" }, error_status: :unauthorized)
      false
    end
  end

  def current_user
    @current_user
  end

  def verify_merchant(merchant_id)
    unless current_user.id.to_s == merchant_id.to_s
      render_response(success: false, errors: { error: "Unauthorized access" }, error_status: :forbidden)
      return false
    end
    true
  end
end
