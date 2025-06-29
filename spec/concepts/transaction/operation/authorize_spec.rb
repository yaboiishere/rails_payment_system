# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction::Operation::Authorize, type: :operation do
  let(:merchant) { create(:merchant, status: :active) }

  let(:valid_params) do
    {
      amount: "100.00",
      customer_email: "client@example.com",
      customer_phone: "1234567890"
    }
  end

  context "with valid inputs" do
    it "creates an authorized transaction" do
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).to be_success
      expect(result[:model]).to be_a(Transaction::Authorize)
      expect(result[:model].status).to eq("approved")
      expect(result[:model].merchant).to eq(merchant)
      expect(merchant.reload.total_transaction_sum).to eq(0) # Authorize does not increase total
    end
  end

  context "with inactive merchant" do
    it "fails and sets error" do
      merchant.update!(status: :inactive)
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).not_to be_success
      expect(result[:errors]).to include("Merchant is not active")
    end
  end

  context "with invalid amount" do
    it "fails with validation error" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(amount: -50)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Amount must be greater than zero")
    end
  end

  context "with invalid email" do
    it "fails with customer email validation error" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(customer_email: "bad")
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Invalid email format")
    end
  end

  context "with missing phone" do
    it "fails with customer phone validation error" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(customer_phone: nil)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Customer email and phone are required")
    end
  end

  context "merchant total sum is not updated" do
    it "does not update merchant total transaction sum" do
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).to be_success
      expect(merchant.reload.total_transaction_sum).to eq(0)
    end
  end

  context "when transaction fails to save" do
    it "returns validation errors" do
      allow_any_instance_of(Transaction::Authorize).to receive(:save).and_return(false)
      allow_any_instance_of(Transaction::Authorize).to receive_message_chain(:errors, :full_messages).and_return([ "Some error" ])

      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).not_to be_success
      expect(result[:errors]).to include("Some error")
    end
  end

  context "when there is parent_transaction" do
    it "fails with validation error" do
      parent_transaction = create(:authorize_transaction, merchant: merchant, amount: 100.00)
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(parent_transaction_uuid: parent_transaction.uuid)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Parent transaction uuid should not be present for authorize transactions")
    end

    it "fails when a non existing parent transaction is provided" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(parent_transaction_uuid: "non-existing-uuid")
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Parent transaction uuid should not be present for authorize transactions")
    end

    it "ignores parent_transaction when params are good in authorize transaction" do
      parent_transaction = create(:authorize_transaction, merchant: merchant, amount: 100.00)
      result = described_class.call(
        merchant: merchant,
        params: valid_params,
        parent_transaction: parent_transaction
      )

      expect(result).to be_success
      expect(result[:model]).to be_a(Transaction::Authorize)
      expect(result[:model].parent_transaction).to be_nil
    end
  end

  context "when input is invalid, transaction is still persisted with error status" do
    it "persists transaction with status error and error message" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(customer_email: "", amount: -10)
      )

      expect(result).not_to be_success
      expect(result[:transaction]).to be_persisted
      expect(result[:transaction].status).to eq("error")
      expect(result[:transaction].error_message).to include("Customer email and phone are required").or include("Amount must be greater than zero")
      expect(result[:transaction].merchant).to eq(merchant)
    end

    it "doesn't persist transaction if merchant is inactive" do
      merchant.update!(status: :inactive)

      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).not_to be_success
      expect(result[:transaction]).to be_nil
      expect(result[:errors]).to include("Merchant is not active")
      expect(result.terminus.to_h[:semantic]).to eq(:merchant_not_found)
    end
  end
end
