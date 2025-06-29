class ApiSessionController < ApiController
  allow_unauthenticated_access only: %i[ create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def create
    if (user = User.authenticate_by(params.permit(:email, :password)))
      jwt = helpers.jwt_encode(user.id)

      render json: { token: jwt }, status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  def index
    render json: { message: "This is the API session index." }, status: :ok
  end
end
