# frozen_string_literal: true

class Transaction
  class Reversal < Transaction
    belongs_to :parent_transaction, class_name: "Transaction::Authorize", required: true
    validates :amount, absence: true
  end
end
