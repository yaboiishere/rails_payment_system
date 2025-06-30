require 'rails_helper'

RSpec.describe MerchantController, type: :controller do
  let!(:admin) { create(:admin) }
  let!(:merchant1) { create(:merchant, email: "a@example.com") }
  let!(:merchant2) { create(:merchant, email: "b@example.com") }

  before do
    Current.session = nil
  end

  describe "GET /merchants" do
    context "as admin" do
      it "returns 200 and lists merchants" do
        sign_in_as(admin)

        get :index

        expect(response).to have_http_status(:ok)
        merchant_presenters = assigns(:merchant_presenters)
        expect(merchant_presenters).to all(be_a(MerchantPresenter))
        expect(merchant_presenters.map(&:email).to_s).to include(merchant1.email, merchant2.email)
        expect(response.body).to render_template("merchant/index")
      end
    end

    context "as merchant" do
      it "is forbidden or redirected" do
        sign_in_as(merchant1)

        get :index

        expect(response).to redirect_to(merchant_path(merchant1))
        expect(assigns(:merchant_presenters)).to be_nil
      end
    end

    context "as guest" do
      it "redirects to login" do
        get :index

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("You must be logged in to access this page.")
        expect(assigns(:merchant_presenters)).to be_nil
      end
    end
  end

  describe "GET /merchants/:id" do
    context "as self (owner)" do
      it "shows their own data" do
        sign_in_as(merchant1)

        get :show, params: { id: merchant1.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:merchant)).to be_a(MerchantPresenter)
        expect(assigns(:merchant).email).to include(merchant1.email)
      end
    end

    context "as admin" do
      it "can view any merchant" do
        sign_in_as(admin)

        get :show, params: { id: merchant1.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:merchant)).to be_a(MerchantPresenter)
        expect(assigns(:merchant).email).to include(merchant1.email)

        get :show, params: { id: merchant2.id }
        expect(response).to have_http_status(:ok)
        expect(assigns(:merchant)).to be_a(MerchantPresenter)
        expect(assigns(:merchant).email).to include(merchant2.email)
      end
    end

    context "as another merchant" do
      it "is forbidden or redirected" do
        sign_in_as(merchant1)

        get :show, params: { id: merchant2.id }

        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to eq("Access denied.")
        expect(response).to redirect_to(merchant_path(merchant1))
      end
    end

    context "as an unauthenticated user" do
      it "redirects to login" do
        get :show, params: { id: merchant1.id }

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("You must be logged in to access this page.")
        expect(assigns(:merchant)).to be_nil
      end
    end
  end
end
