# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Admin, type: :model do
  let(:admin) { build(:admin) }

  it 'is valid with valid attributes' do
    expect(admin).to be_valid
  end

  it 'inherits from User' do
    expect(User::Admin.superclass).to eq(User)
    expect(admin).to be_a(User)
  end

  it 'sets type to "Admin"' do
    admin.save
    expect(admin.reload.type).to eq("User::Admin")
  end

  it 'returns true for #admin? method' do
    expect(admin.admin?).to be true
  end

  it 'allows nil for total_transaction_sum' do
    admin.total_transaction_sum = nil
    expect(admin).to be_valid
  end
end
