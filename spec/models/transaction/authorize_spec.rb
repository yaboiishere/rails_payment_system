# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction::Authorize, type: :model do
  let(:transaction) { build(:authorize_transaction) }

  it 'inherits from Transaction' do
    expect(transaction).to be_a(Transaction)
  end

  it 'is authorize transaction' do
    expect(transaction).to be_a(Transaction::Authorize)
  end

  it 'is valid with valid attributes' do
    expect(transaction).to be_valid
  end

  it 'is invalid without amount' do
    transaction.amount = nil
    expect(transaction).not_to be_valid
    expect(transaction.errors[:amount]).to include("is not a number")
  end

  it 'parent is nil' do
    expect(transaction.parent_transaction).to be_nil
  end

  it 'is invalid if parent is not nil' do
    wrong_transaction = build(:refund_transaction)
    transaction.parent_transaction = wrong_transaction
    expect(transaction).not_to be_valid
    expect(transaction.errors[:parent_transaction]).to include("must be blank")
  end
end
