# frozen_string_literal: true

class Transaction
  class Authorize < Transaction
    # This transaction holds the customer's funds and is used to initiate the payment process,
    # because of this it does not have a parent transaction.
    validates :parent_transaction, absence: true
  end
end
