require 'rails_helper'

RSpec.describe "Transactions", type: :request do
  describe "GET /show" do
    let(:admin) { create(:admin) }
    let(:merchant) { create(:merchant) }
    let(:other_merchant) { create(:merchant) }
    let(:transaction) { create(:authorize_transaction, merchant: merchant) }
    context "when user is admin" do
      it "shows the transaction details" do
        sign_in_as(admin)

        get merchant_transaction_path(merchant, transaction)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(transaction.uuid)
        expect(response.body).to include(transaction.amount.to_s)
        expect(response.body).to include(transaction.status.titleize)
        expect(response.body).to include(transaction.customer_email)
        expect(response.body).to include(transaction.customer_phone)
      end

      it "returns a 404 for non-existent transaction" do
        sign_in_as(admin)
        get merchant_transaction_path(merchant, "non-existent-uuid")

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is owner" do
      it "shows the transaction details" do
        sign_in_as(merchant)

        get merchant_transaction_path(merchant, transaction)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(transaction.uuid)
        expect(response.body).to include(transaction.amount.to_s)
        expect(response.body).to include(transaction.status.titleize)
        expect(response.body).to include(transaction.customer_email)
        expect(response.body).to include(transaction.customer_phone)
      end

      it "returns a 404 for non-existent transaction" do
        sign_in_as(merchant)
        get merchant_transaction_path(merchant, "non-existent-uuid")

        expect(response).to redirect_to(merchant_path(merchant))
      end
    end

    context "when user is not owner" do
      it "does not show the transaction details" do
        sign_in_as(other_merchant)

        get merchant_transaction_path(merchant, transaction)

        expect(response).to redirect_to(merchant_path(other_merchant))
        expect(response.body).not_to include(transaction.uuid)
        expect(response.body).not_to include(transaction.amount.to_s)
        expect(response.body).not_to include(transaction.status.titleize)
        expect(response.body).not_to include(transaction.customer_email)
        expect(response.body).not_to include(transaction.customer_phone)
      end

      it "does not allow merchant to look up another merchant's transaction" do
        sign_in_as(other_merchant)

        get merchant_transaction_path(merchant, transaction)

        expect(response).to redirect_to(merchant_path(other_merchant))
        expect(flash[:alert]).to eq("Access denied.")
      end

      it "returns a 404 for non-existent transaction" do
        sign_in_as(other_merchant)
        get merchant_transaction_path(merchant, "non-existent-uuid")

        expect(response).to redirect_to(merchant_path(other_merchant))
        expect(flash[:alert]).to eq("Access denied.")
      end
    end

    context "when there is no user" do
      it "redirects to the login page" do
        get merchant_transaction_path(merchant, transaction)

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("You must be logged in to access this page.")
      end
    end
  end
end
