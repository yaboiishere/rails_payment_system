# frozen_string_literal: true

class User
  class Merchant < User
    before_validation :set_default_total_transaction_sum

    has_many :transactions, dependent: :restrict_with_error
    validates :total_transaction_sum, numericality: { greater_than_or_equal_to: 0 }

    private

    def set_default_total_transaction_sum
      self.total_transaction_sum ||= 0
    end
  end
end
