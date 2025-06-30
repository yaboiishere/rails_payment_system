require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    context "as admin" do
      let!(:admin) { create(:admin) }

      before do
        sign_in_as(admin)
      end

      it "returns http success and renders the index template" do
        get root_path

        expect(response).to redirect_to(merchant_index_path)
      end
    end
    context "as merchant" do
      let!(:merchant) { create(:merchant, email: "merchant1@payment.com") }
      before do
        sign_in_as(merchant)
      end

      it "returns http success and renders the index template" do
        get root_path

        expect(response).to redirect_to(merchant_path(merchant))
      end
    end

    context "as unauthenticated user" do
      it "redirects to the login page" do
        get root_path

        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
