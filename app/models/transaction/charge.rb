# frozen_string_literal: true

class Transaction
  class Charge < Transaction
    # This transaction is used to charge the customer and is a child of an authorize transaction.
    # It moves the funds from the customer's account to the merchant's account.
    #
    # It is a child of an authorize transaction
    belongs_to :parent_transaction, class_name: "Transaction::Authorize", required: true
  end
end
