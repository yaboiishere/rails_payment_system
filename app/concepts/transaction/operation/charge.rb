# frozen_string_literal: true

module Transaction::Operation
  class Charge < Trailblazer::Operation
    include Transaction::Operation::Shared

    step :tx_type
    step :validate_merchant
    step :validate_customer
    step :set_parent_transaction
    step :validate_parent_transaction
    step :validate_amount
    step :build_model
    step :persist
    step :update_merchant_total

    def tx_type(ctx, **)
      ctx[:tx_type] = :charge
      true
    end

    def build_model(ctx, merchant:, parent_transaction:, params:, **)
      ctx[:transaction] = Transaction::Charge.new(
        merchant: merchant,
        parent_transaction: parent_transaction,
        amount: params[:amount],
        status: :approved,
        customer_email: params[:customer_email],
        customer_phone: params[:customer_phone]
      )
    end
  end
end
