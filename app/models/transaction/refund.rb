# frozen_string_literal: true

class Transaction
  class Refund < Transaction
    # This transaction is used to reverse a charge transaction and refund the whole amount back to the customer.
    #
    # It is a child of a charge transaction.
    belongs_to :parent_transaction, class_name: "Transaction::Charge", required: true
  end
end
