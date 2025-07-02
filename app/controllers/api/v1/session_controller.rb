class Api::V1::SessionController < Api::BaseController
  allow_unauthenticated_access only: %i[ create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def create
    # jwt = jwt_encode(user.id) if user = User.authenticate_by(session_params)
    user = User.authenticate_by(session_params)
    jwt = user ? jwt_encode(user.id) : nil

    render_response(success: jwt, data: { token: jwt }, errors: { error: "Invalid username or password" }, error_status: :unauthorized)
  end

  def index
    render_response(success: true, data: { message: "This is the API session index." })
  end

  private

  def session_params
    if is_xml?
      params.require(:session).permit(:email, :password)
    else
      params.permit(:email, :password)
    end
  end
end
