# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionHelper, type: :helper do
  { "approved" => "success", "refunded" => "warning", "reversed" => "secondary", "error" => "danger", "otherwise" => "light" }.each do |status, expected_class|
    it "returns '#{expected_class}' for status '#{status}'" do
      expect(helper.status_badge_class(status)).to eq(expected_class)
    end
  end
end
