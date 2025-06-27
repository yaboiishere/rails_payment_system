# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  it 'is valid with valid attributes' do
    expect(user).to be_valid
  end

  it 'is invalid without a name' do
    user.name = nil
    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it 'is invalid without an email' do
    user.email = nil
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid with improperly formatted email' do
    user.email = "invalidemail"
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is invalid")
  end

  it 'is valid with properly formatted email' do
    user.email = "valid@example.com"
    expect(user).to be_valid
  end

  it 'is invalid with nil status' do
    user.status = nil
    expect(user).not_to be_valid
  end

  it 'is throwing with non existant status' do
    expect { user.status = 'non_existent_status' }.to raise_error ArgumentError
  end

  it 'is not admin' do
    expect(user.admin?).to be false
  end
end
