# frozen_string_literal: true

class Transaction
  class Charge < Transaction
    belongs_to :parent_transaction, class_name: "Transaction::Authorize", required: true
  end
end
