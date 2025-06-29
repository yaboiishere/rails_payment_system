# frozen_string_literal: true

module Transaction::Operation
  class Authorize < Trailblazer::Operation
    include Transaction::Operation::Shared

    step ->(ctx, **) { ctx[:tx_type] = Transaction::Authorize }
    step :validate_merchant
    step :validate_customer
    step :validate_amount
    step :validate_no_parent_transaction

    fail :persist_failed_transaction

    step :build_model
    step :persist

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

    def validate_no_parent_transaction(ctx, params:, **)
      parent_transaction_uuid = params[:parent_transaction_uuid]
      if parent_transaction_uuid.present?
        ctx[:errors] ||= []
        ctx[:errors] << "Parent transaction uuid should not be present for authorize transactions"
        false
      else
        true
      end
    end
  end
end
