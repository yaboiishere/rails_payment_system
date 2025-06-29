# frozen_string_literal: true

module Transaction::Operation
  class Reversal < Trailblazer::Operation
    include Transaction::Operation::Shared

    step ->(ctx, **) { ctx[:tx_type] = Transaction::Reversal }
    step :validate_merchant
    step :validate_customer
    step :validate_amount
    step :set_parent_transaction
    step :is_parent_approved?
    step :validate_parent_transaction

    fail :persist_failed_transaction

    step :build_model
    step :persist
    step :update_parent_transaction

    def validate_amount(ctx, params:, **)
      if params[:amount].present?
        ctx[:errors] ||= []
        ctx[:errors] << "Amount must be nil for reversal transactions"
        false
      else
        true
      end
    end

    def validate_parent_transaction(ctx, parent_transaction:, **)
      if parent_transaction.is_a?(Transaction::Authorize)
        true
      else
        ctx[:errors] << "Parent transaction must be an authorize transaction"
        ctx[:parent_transaction] = nil
        false
      end
    end

    def build_model(ctx, merchant:, parent_transaction:, params:, **)
      ctx[:transaction] = Transaction::Reversal.new(
        merchant: merchant,
        parent_transaction: parent_transaction,
        amount: nil,
        status: :approved,
        customer_email: params[:customer_email],
        customer_phone: params[:customer_phone]
      )
    end

    def update_parent_transaction(ctx, parent_transaction:, **)
      parent_transaction.status = :reversed
      if parent_transaction.save
        ctx[:parent_transaction] = parent_transaction
        true
      else
        ctx[:errors] ||= []
        ctx[:errors] << "Failed to update parent transaction status"
        false
      end
    end
  end
end
