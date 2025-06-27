# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction::Reversal, type: :model do
  let(:transaction) { build(:reversal_transaction) }

  it 'inherits from Transaction' do
    expect(transaction).to be_a(Transaction)
  end

  it 'is reversal transaction' do
    expect(transaction).to be_a(Transaction::Reversal)
  end

  it 'is valid with valid attributes' do
    transaction.amount = nil
    expect(transaction).to be_valid
  end

  it 'is invalid with amount' do
    transaction.amount = 100
    expect(transaction).not_to be_valid
    expect(transaction.errors[:amount]).to include("must be blank")
  end

  it 'parent is a authorize transaction' do
    expect(transaction.parent_transaction).to be_a(Transaction::Authorize)
  end

  it 'throws error if parent is not authorize transaction' do
    wrong_transaction = build(:refund_transaction)
    expect { transaction.parent_transaction = wrong_transaction }.to raise_error(ActiveRecord::AssociationTypeMismatch)
  end
end
