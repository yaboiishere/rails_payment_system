# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MerchantPresenter do
  let(:merchant) { create(:merchant, status: :active, total_transaction_sum: 100.0) }
  subject(:presenter) { described_class.new(merchant) }

  it "returns the merchant's name" do
    expect(presenter.name).to eq(merchant.name)
  end

  it "returns formatted currency" do
    expect(presenter.total_sum).to eq("$100.00")
  end

  it "returns a status badge" do
    expect(presenter.status_badge).to include("badge")
  end

  it "returns email with mailto link" do
    expect(presenter.email).to include('href="mailto:')
    expect(presenter.email).to include(merchant.email)
    expect(presenter.email).to include('">')
  end

  it "returns created at in a readable format" do
    expect(presenter.created_at).to include(merchant.created_at.strftime("%Y-%m-%d %H:%M"))
  end

  it "returns user path link" do
    expect(presenter.link).to eq("/merchant/#{merchant.id}")
  end

  it "returns transactions as TransactionPresenter objects" do
    transaction = create(:transaction, merchant: merchant)
    expect(presenter.transactions).to all(be_a(TransactionPresenter))
    expect(presenter.transactions.first.transaction).to eq(transaction)
  end

  it "returns the total number of transactions" do
    create_list(:transaction, 3, merchant: merchant)
    expect(presenter.transactions_total).to eq(3)
  end
end
