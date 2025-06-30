# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionPresenter do
  let(:transaction) { create(:authorize_transaction) }
  subject(:presenter) { described_class.new(transaction) }

  it "returns the transaction's UUID" do
    expect(presenter.uuid).to eq(transaction.uuid)
  end

  it "returns the transaction's uuid link" do
    expect(presenter.link).to include("/merchant/#{transaction.merchant.id}/transaction/#{transaction.id}")
  end

  { authorize_transaction: "Authorize", charge_transaction: "Charge", refund_transaction: "Refund", reversal_transaction: "Reversal" }.each do |type, label|
    it "returns the transaction type as '#{label}'" do
      transaction = build(type)
      presenter = described_class.new(transaction)
      expect(presenter.type_label).to eq(label)
    end

    it "returns the transaction type badge as '#{label}'" do
      transaction = build(type)
      presenter = described_class.new(transaction)
      expect(presenter.type_label_badge).to include('<span class="badge ')
      expect(presenter.type_label_badge).to include(label)
      expect(presenter.type_label_badge).to include("</span>")
    end
  end

  it "returns the transaction type badge as 'Unknown' for an unknown type" do
    transaction = build(:transaction, type: "UnknownTransactionType")
    presenter = described_class.new(transaction)
    expect(presenter.type_label_badge).to include('<span class="badge ')
    expect(presenter.type_label_badge).to include("Unknown")
    expect(presenter.type_label_badge).to include("</span>")
  end

  it "returns the transactions type label" do
    expect(presenter.type_label).to eq("Authorize")
  end

  it "returns the transaction's amount if present" do
    expect(presenter.amount).to eq("$100.00")
  end

  it "returns the transaction's amount if not present" do
    transaction.amount = nil
    presenter = described_class.new(transaction)
    expect(presenter.amount).to eq("-")
  end

  %w[approved error refunded reversed].each do |status|
    it "returns the transaction's status badge as '#{status}'" do
      transaction.status = status
      presenter = described_class.new(transaction)
      expect(presenter.status_badge).to include('<span class="badge bg-')
      expect(presenter.status_badge).to include(status.titleize)
      expect(presenter.status_badge).to include("</span>")
    end
  end

  it "returns the transaction's created_at in a readable format" do
    expect(presenter.created_at).to include(transaction.created_at.strftime("%Y-%m-%d %H:%M"))
  end

  it "returns the transaction's customer email" do
    expect(presenter.customer_email).to eq(transaction.customer_email)
  end

  it "returns the transaction's customer phone" do
    expect(presenter.customer_phone).to eq(transaction.customer_phone)
  end

  it "returns a link to the transaction parent when it exists" do
    parent_transaction = create(:authorize_transaction)
    charge_transaction = create(:charge_transaction, parent_transaction: parent_transaction)
    presenter = described_class.new(charge_transaction)
    link = presenter.parent_uuid_link
    expect(link).to include("<a class=")
    expect(link).to include("merchant/#{charge_transaction.merchant.id}/transaction/#{parent_transaction.id}")
    expect(link).to include(parent_transaction.uuid)
  end

  it "returns '-' when there is no parent transaction" do
    expect(presenter.parent_uuid_link).to eq("-")
  end

  it "returns a link to the merchant" do
    expect(presenter.merchant_link).to include("<a class=")
    expect(presenter.merchant_link).to include("href=\"/merchant/#{transaction.merchant.id}\">")
    expect(presenter.merchant_link).to include(transaction.merchant.name)
    expect(presenter.merchant_link).to include("</a>")
  end
end
