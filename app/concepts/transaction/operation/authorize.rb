# frozen_string_literal: true

module Transaction::Operation
  class Authorize < Trailblazer::Operation
    include Transaction::Operation::Shared

    step :tx_type
    step :validate_merchant
    step :validate_customer
    step :set_parent_transaction
    step :validate_parent_transaction
    step :validate_amount
    step :build_model
    step :persist

    def tx_type(ctx, **)
      ctx[:tx_type] = :authorize
      true
    end

    def build_model(ctx, merchant:, params:, **)
      ctx[:transaction] = Transaction::Authorize.new(
        merchant: merchant,
        parent_transaction: nil,
        amount: params[:amount],
        status: :approved,
        customer_email: params[:customer_email],
        customer_phone: params[:customer_phone]
      )
    end
  end
end
