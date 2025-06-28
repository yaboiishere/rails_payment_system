# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction::Operation::Charge, type: :operation do
  let(:merchant) { create(:merchant, status: :active) }

  let(:authorize_transaction) { create(:authorize_transaction) }

  let(:valid_params) do
    {
      parent_transaction_uuid: authorize_transaction.uuid,
      amount: authorize_transaction.amount,
      customer_email: "client@example.com",
      customer_phone: "1234567890"
    }
  end

  context "with valid inputs" do
    it "creates an authorized transaction" do
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).to be_success
      expect(result[:model]).to be_a(Transaction::Charge)
      expect(result[:model].status).to eq("approved")
      expect(result[:model].merchant).to eq(merchant)
      expect(result[:model].parent_transaction).to eq(authorize_transaction)
      expect(merchant.reload.total_transaction_sum).to eq(authorize_transaction.amount)
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
      expect(result[:errors]).to include("Parent transaction must be an authorize transaction")
    end

    it "fails when parent transaction is not an authorize transaction" do
      wrong_parent = create(:refund_transaction)
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(parent_transaction_uuid: wrong_parent)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Parent transaction not found")
    end
  end

  context "with invalid amount" do
    it "fails with validation error" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(amount: -50)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Amount must be the same as the authorize transaction amount")
    end

    it "fails with wrong amount" do
      result = described_class.call(
        merchant: merchant,
        params: valid_params.merge(amount: 0)
      )

      expect(result).not_to be_success
      expect(result[:errors]).to include("Amount must be the same as the authorize transaction amount")
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

  context "merchant total sum is updated" do
    it "updates merchant total transaction sum" do
      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).to be_success
      expect(merchant.reload.total_transaction_sum).to eq(authorize_transaction.amount)
    end

    it "fails to update merchant total transaction sum" do
      allow_any_instance_of(User::Merchant).to receive(:save).and_return(false)

      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).not_to be_success
      expect(result[:errors]).to include("Failed to update merchant total")
    end
  end

  context "when transaction fails to save" do
    it "returns validation errors" do
      allow_any_instance_of(Transaction::Charge).to receive(:save).and_return(false)
      allow_any_instance_of(Transaction::Charge).to receive_message_chain(:errors, :full_messages).and_return([ "Some error" ])

      result = described_class.call(merchant: merchant, params: valid_params)

      expect(result).not_to be_success
      expect(result[:errors]).to include("Some error")
    end
  end
end
