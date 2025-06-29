require 'rails_helper'
include ApiSessionHelper

RSpec.describe "ApiSessionController", type: :request do
  let(:user) { create(:user, email: "test@example.com", password: "password") }

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
    let(:token) { jwt_encode(user.id) }
    let(:bad_token) { jwt_encode(-1) } # Invalid user ID

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
  end
end
