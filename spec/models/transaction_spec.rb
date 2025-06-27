require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:transaction) { build(:transaction) }
  it 'is valid with valid attributes' do
    expect(transaction).to be_valid
  end

  it 'generates a UUID if none is provided' do
    transaction.uuid = nil
    transaction.valid?
    expect(transaction.uuid).to be_present
  end

  it 'rejects an invalid status' do
    expect { transaction.status = 'invalid' }.to raise_exception ArgumentError
  end

  it 'requires amount > 0' do
    transaction.amount = -10
    expect(transaction).not_to be_valid
  end

  it 'rejects malformed customer_email' do
    transaction.customer_email = 'invalidemail'
    expect(transaction).not_to be_valid
  end

  it 'belongs to a user of type Merchant' do
    expect(transaction.merchant).to be_a(User::Merchant)
  end
end
