# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let!(:merchant) { create(:merchant, email: "merchant@example.com", password: "Password@123") }

  describe "GET #new" do
    it "renders the login page" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      it "logs in and redirects to root or return path" do
        post :create, params: { email: merchant.email, password: merchant.password }

        expect(cookies.signed[:session_id]).to be_present
        expect(response).to redirect_to(root_path)
      end

      it "redirects to return path if session[:return_to_after_authenticating] is set" do
        session[:return_to_after_authenticating] = "/made-up-path"

        post :create, params: { email: merchant.email, password: merchant.password }

        expect(response).to redirect_to("/made-up-path")
      end
    end

    context "with invalid credentials" do
      it "redirects back to login with alert" do
        post :create, params: { email: merchant.email, password: "wrongpass" }

        expect(Current.session).to be_nil
        expect(flash[:alert]).to match(/Try another email address or password/)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      session_record = merchant.sessions.create!(user_agent: "RSpec", ip_address: "127.0.0.1")
      cookies.signed[:session_id] = session_record.id
      Current.session = session_record
    end

    it "logs out and clears session" do
      delete :destroy

      expect(Current.session).to be_nil
      expect(cookies[:session_id]).to be_nil
      expect(response).to redirect_to(new_session_path)
    end
  end
end
