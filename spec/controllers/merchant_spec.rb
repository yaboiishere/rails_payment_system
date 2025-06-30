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

  describe "DELETE /merchants/:id" do
    context "as admin" do
      it "deletes the merchant" do
        sign_in_as(admin)

        expect {
          delete :destroy, params: { id: merchant1.id }
        }.to change(User::Merchant, :count).by(-1)

        expect(response).to redirect_to(merchant_index_path)
        expect(flash[:notice]).to eq("Merchant deleted successfully.")
      end

      it "does not delete the merchant if there are transactions" do
        create(:transaction, merchant: merchant1)

        sign_in_as(admin)

        expect {
          delete :destroy, params: { id: merchant1.id }
        }.not_to change(User::Merchant, :count)

        expect(response).to redirect_to(merchant_index_path)
        expect(flash[:alert]).to eq("Cannot delete record because dependent transactions exist")
      end
    end

    context "as owner" do
      it "is forbidden or redirected" do
        sign_in_as(merchant1)

        delete :destroy, params: { id: merchant1.id }

        expect(response).to redirect_to(merchant_path(merchant1))
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "as guest" do
      it "redirects to login" do
        delete :destroy, params: { id: merchant1.id }

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("You must be logged in to access this page.")
      end
    end
  end

  describe "GET /merchants/:id/edit" do
    context "as admin" do
      it "allows editing any merchant" do
        sign_in_as(admin)

        get :edit, params: { id: merchant1.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:merchant)).to be_a(User::Merchant)
        expect(assigns(:form)).to be_a(MerchantForm)
        expect(assigns(:form).email).to eq(merchant1.email)
      end
    end

    context "as owner" do
      it "allows editing their own merchant" do
        sign_in_as(merchant1)

        get :edit, params: { id: merchant1.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:merchant)).to be_a(User::Merchant)
        expect(assigns(:form)).to be_a(MerchantForm)
        expect(assigns(:form).email).to eq(merchant1.email)
      end
    end

    context "as another merchant" do
      it "is forbidden or redirected" do
        sign_in_as(merchant2)

        get :edit, params: { id: merchant1.id }

        expect(response).to redirect_to(merchant_path(merchant2))
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "as guest" do
      it "redirects to login" do
        get :edit, params: { id: merchant1.id }

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("You must be logged in to access this page.")
      end
    end
  end

  describe "PATCH /merchants/:id" do
    context "as admin" do
      it "updates any merchant" do
        sign_in_as(admin)

        patch :update, params: { id: merchant1.id, merchant_form: { email: "new_email@payment.com", status: "active" } }
        expect(response).to redirect_to(merchant_path(merchant1))
        expect(flash[:notice]).to eq("Merchant updated successfully.")
        expect(merchant1.reload.email).to eq("new_email@payment.com")
        expect(merchant1.status).to eq("active")
      end
      it "does not update with invalid data" do
        sign_in_as(admin)

        patch :update, params: { id: merchant1.id, merchant_form: { email: "invalid_email", status: "unknown" } }

        expect(response).to render_template(:edit)
        expect(flash.now[:alert]).to eq("Could not update merchant.")
        expect(merchant1.reload.email).not_to eq("invalid_email")
      end
    end
    context "as owner" do
      it "updates their own merchant" do
        sign_in_as(merchant1)

        patch :update, params: { id: merchant1.id, merchant_form: { email: "new_email@payment.com", status: "active" } }
        expect(response).to redirect_to(merchant_path(merchant1))
        expect(flash[:notice]).to eq("Merchant updated successfully.")
        expect(merchant1.reload.email).to eq("new_email@payment.com")
        expect(merchant1.status).to eq("active")
      end
      it "does not update with invalid data" do
        sign_in_as(merchant1)

        patch :update, params: { id: merchant1.id, merchant_form: { email: "invalid_email", status: "unknown" } }

        expect(response).to render_template(:edit)
        expect(flash.now[:alert]).to eq("Could not update merchant.")
        expect(merchant1.reload.email).not_to eq("invalid_email")
      end
    end
    context "as another merchant" do
      it "is forbidden or redirected" do
        sign_in_as(merchant2)

        patch :update, params: { id: merchant1.id, merchant_form: { email: "new_email@payment.com", status: "active" } }
        expect(response).to redirect_to(merchant_path(merchant2))
        expect(flash[:alert]).to eq("Access denied.")
      end
    end
    context "as guest" do
      it "redirects to login" do
        patch :update, params: { id: merchant1.id, merchant_form: { email: "new_email@payment.com", status: "active" } }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("You must be logged in to access this page.")
      end
    end
  end
end
