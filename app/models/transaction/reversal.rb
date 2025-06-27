# frozen_string_literal: true

class Transaction
  class Reversal < Transaction
    # This transaction is used to release the hold on funds that were previously authorized.
    #
    # It is a child of an authorize transaction.
    belongs_to :parent_transaction, class_name: "Transaction::Authorize", required: true
    validates :amount, absence: true
  end
end
