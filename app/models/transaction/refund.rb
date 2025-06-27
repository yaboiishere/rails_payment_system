# frozen_string_literal: true

class Transaction
  class Refund < Transaction
    belongs_to :parent_transaction, class_name: "Transaction::Charge", required: true
  end
end
