class Api::V1::SessionController < Api::BaseController
  allow_unauthenticated_access only: %i[ create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def create
    if (user = User.authenticate_by(session_params))
      jwt = jwt_encode(user.id)

      if is_xml?
        render xml: { token: jwt }, status: :ok
      else
        render json: { token: jwt }, status: :ok
      end
    else
      if is_xml?
        render xml: { error: "Invalid username or password" }, status: :unauthorized
      else
        render json: { error: "Invalid username or password" }, status: :unauthorized
      end
    end
  end

  def index
    if is_xml?
      render xml: { message: "This is the API session index." }, status: :ok
    else
      render json: { message: "This is the API session index." }, status: :ok
    end
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
