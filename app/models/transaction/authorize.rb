# frozen_string_literal: true

class Transaction
  class Authorize < Transaction
    validates :parent_transaction, absence: true
  end
end
