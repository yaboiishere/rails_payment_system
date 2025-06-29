require 'rails_helper'

RSpec.describe "ApiSessionController", type: :request do
  let(:user) { create(:user, email: "test@example.com", password: "password") }
  let(:jwt_helper) do
    Class.new do
      include ApiSessionHelper
    end.new
  end

  describe "POST /api_session" do
    context "with valid credentials" do
      it "returns a JWT token" do
        post api_session_index_path, params: { email: user.email, password: user.password }

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["token"]).to be_a(String)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized error" do
        post api_session_index_path, params: { email: "wrong@example.com", password: "password" }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Invalid username or password")
      end
    end
  end

  describe "GET /api_session" do
    let(:token) { jwt_helper.jwt_encode(user.id) }
    let(:bad_token) { jwt_helper.jwt_encode(-1) } # Invalid user ID

    context "with valid JWT" do
      it "returns success" do
        get api_session_index_path, headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("message" => "This is the API session index.")
      end
    end

    context "with missing JWT" do
      it "returns unauthorized" do
        get api_session_index_path

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Missing token")
      end
    end

    context "with invalid JWT" do
      it "returns unauthorized" do
        get api_session_index_path, headers: { "Authorization" => "Bearer invalid.token" }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Invalid token")
      end
    end

    context "with valid JWT but no matching user" do
      it "returns unauthorized" do
        get api_session_index_path, headers: { "Authorization" => "Bearer #{bad_token}" }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Invalid session")
      end
    end
    context 'with an expired token' do
      it 'returns success? false and an expiration error' do
        expired_payload = {
          payload: { user_id: user.id },
          expires_at: 1.minute.ago.to_i
        }

        expired_token = JWT.encode(expired_payload, Rails.application.credentials.secret_key_base)

        result = jwt_helper.jwt_decode(expired_token)

        expect(result[:success?]).to be false
        expect(result[:error]).to eq('Token has expired')
      end
    end
  end
end
