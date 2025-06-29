# frozen_string_literal: true

module Transaction::Operation
  class Charge < Trailblazer::Operation
    include Transaction::Operation::Shared

    step ->(ctx, **) { ctx[:tx_type] = Transaction::Charge }
    step :validate_merchant, Output(:failure) => End(:merchant_not_found)
    step :validate_customer
    step :validate_amount
    step :set_parent_transaction
    step :is_parent_approved?
    step :validate_parent_transaction

    fail :persist_failed_transaction

    step :build_model
    step :persist
    step :update_merchant_total

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

    def validate_parent_transaction(ctx, parent_transaction:, params:, **)
      amount = params[:amount].to_d
      ctx[:errors] ||= []
      if parent_transaction.is_a?(Transaction::Authorize)
        # TODO: check if the amount should be the same as in the authorize transaction or just lower or equal to
        if parent_transaction.amount == amount
          true
        else
          ctx[:errors] << "Amount must be the same as the authorize transaction amount"
          false
        end
      else
        ctx[:errors] << "Parent transaction must be an authorize transaction"
        ctx[:parent_transaction] = nil
        false
      end
    end

    def update_merchant_total(ctx, model:, **)
      if model.is_approved?
        if model.merchant.increment(:total_transaction_sum, model.amount).save
          true
        else
          ctx[:errors] << "Failed to update merchant total"
          false
        end
      else
        ctx[:errors] ||= []
        ctx[:errors] << "Transaction is not approved, cannot update merchant total"
        false
      end
    end
  end
end
