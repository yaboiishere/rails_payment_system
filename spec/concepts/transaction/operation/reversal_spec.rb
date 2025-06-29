# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction::Operation::Reversal, type: :operation do
  let(:merchant) { create(:merchant, status: :active) }

  let(:authorize_transaction) {
    create(:authorize_transaction, merchant: merchant) }

  let(:valid_params) do
    {
      parent_transaction_uuid: authorize_transaction.uuid,
      amount: nil,
      customer_email: "client@example.com",
      customer_phone: "1234567890"
    }
  end

  context "with valid inputs" do
    it "creates a reversed transaction" do
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).to be_success
      expect(result[:model]).to be_a(Transaction::Reversal)
      expect(result[:model].status).to eq("approved")
      expect(result[:model].merchant).to eq(merchant)
      expect(result[:model].amount).to be_nil
      expect(result[:model].parent_transaction).to be_a(Transaction::Authorize)
      expect(result[:model].parent_transaction.uuid).to eq(authorize_transaction.uuid)
      expect(result[:model].parent_transaction.status).to eq("reversed")
      expect(merchant.reload.total_transaction_sum).to eq(0)
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

  context "with invalid parent transaction" do
    it "fails when no parent transaction is provided" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(parent_transaction_uuid: nil)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("parent_transaction_uuid is missing")
    end

    it "fails when parent transaction is not a authorize transaction" do
      wrong_parent = create(:refund_transaction)
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(parent_transaction_uuid: wrong_parent.uuid)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Parent transaction must be an authorize transaction")
    end

    it "fails when parent transaction is not found" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(parent_transaction_uuid: "non-existent-uuid")
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Parent transaction not found")
    end
    it "fails when parent transaction is not approved" do
      pending_parent = create(:authorize_transaction, status: "reversed")
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(parent_transaction_uuid: pending_parent.uuid)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Parent transaction must be approved")
    end
  end

  context "with invalid amount" do
    it "fails with validation error" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(amount: -50)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Amount must be nil for reversal transactions")
    end

    it "fails with wrong amount" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(amount: 123)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Amount must be nil for reversal transactions")
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
    it "doesn't update merchant total transaction sum" do
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).to be_success
      expect(merchant.reload.total_transaction_sum).to eq(0)
    end
  end

  context "when transaction fails to save" do
    it "returns validation errors" do
      allow_any_instance_of(Transaction::Reversal).to receive(:save).and_return(false)
      allow_any_instance_of(Transaction::Reversal).to receive_message_chain(:errors, :full_messages).and_return([ "Some error" ])

      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).not_to be_success
      expect(result[:errors]).to include("Some error")
    end

    it "fails to save parent transaction" do
      allow_any_instance_of(Transaction::Authorize).to receive(:save).and_return(false)
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).not_to be_success
      expect(result[:errors]).to include("Failed to update parent transaction status")
    end
  end
end
