# frozen_string_literal: true

require "rails_helper"

RSpec.describe User::Create, type: :operation do
  let(:valid_common_params) do
    {
      email: "new@example.com",
      name: "New User",
      status: "active",
      password: "Secret123@",
      password_confirmation: "Secret123@"
    }
  end

  context "with merchant user type" do
    it "creates a merchant user" do
      result = described_class.call(params: valid_common_params.merge(type: "merchant"))

      expect(result).to be_success
      expect(result[:model]).to be_a(User::Merchant)
      expect(result[:model].email).to eq("new@example.com")
    end
  end

  context "with admin user type" do
    it "creates an admin user" do
      result = described_class.call(params: valid_common_params.merge(type: "admin"))

      expect(result).to be_success
      expect(result[:model]).to be_a(User::Admin)
    end
  end

  context "with invalid user_type" do
    it "fails with an error message" do
      result = described_class.call(params: valid_common_params.merge(type: "client"))

      expect(result).not_to be_success
      expect(result[:errors]).to include("Invalid user type: client. Valid types are: merchant, admin")
    end
  end

  context "with missing  parameter" do
    it "fails with an error message" do
      result = described_class.call(params: valid_common_params.except(:type))

      expect(result).not_to be_success
      expect(result[:errors]).to include("Missing type parameter. Valid types are: merchant, admin")
    end

    context "with missing required fields" do
      it "fails with validation errors" do
        result = described_class.call(params: valid_common_params.merge(type: "admin").except(:email))

        expect(result).not_to be_success
        expect(result[:errors]).to include("Email can't be blank")
      end
    end
  end

  context "with invalid password" do
    it "fails with validation errors" do
      result = described_class.call(params: valid_common_params.merge(password: "short", password_confirmation: "short", type: "merchant"))

      expect(result).not_to be_success
      expect(result[:errors]).to include("Password must include at least one lowercase letter, one uppercase letter, one digit, and needs to be minimum 8 characters.")
    end
  end
end
