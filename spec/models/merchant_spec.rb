# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Merchant, type: :model do
  let(:merchant) { build(:merchant) }

  it 'is valid with valid attributes' do
    expect(merchant).to be_valid
  end

  it 'sets total_transaction_sum to 0 if nil' do
    merchant.total_transaction_sum = nil
    merchant.valid?
    expect(merchant.total_transaction_sum).to eq(0)
  end

  it 'is invalid with negative total_transaction_sum' do
    merchant.total_transaction_sum = -10
    expect(merchant).not_to be_valid
  end

  it 'returns false for #admin? method' do
    expect(merchant.admin?).to be false
  end

  it 'sets type to "Merchant"' do
    merchant.save
    expect(merchant.reload.type).to eq("User::Merchant")
  end
end
