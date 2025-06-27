# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction::Refund, type: :model do
  let(:transaction) { build(:refund_transaction) }

  it 'inherits from Transaction' do
    expect(transaction).to be_a(Transaction)
  end

  it 'is authorize transaction' do
    expect(transaction).to be_a(Transaction::Refund)
  end

  it 'is valid with valid attributes' do
    expect(transaction).to be_valid
  end

  it 'is invalid without amount' do
    transaction.amount = nil
    expect(transaction).not_to be_valid
    expect(transaction.errors[:amount]).to include("is not a number")
  end

  it 'parent is charge transaction' do
    expect(transaction.parent_transaction).to be_a(Transaction::Charge)
  end

  it 'throws error if parent is not a charge transaction' do
    wrong_transaction = build(:refund_transaction)
    expect { transaction.parent_transaction = wrong_transaction }.to raise_error(ActiveRecord::AssociationTypeMismatch)
  end
end
