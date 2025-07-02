# frozen_string_literal: true

class Api::V1::TransactionController < Api::BaseController
  def create
    check_idempotency do
      return unless verify_merchant(transaction_params[:merchant_id])

      Transaction::Create.call(params: transaction_params)
    end
  end

  private

  def transaction_params
    if is_xml?
      params.require(:transaction).permit(
        :amount, :customer_email, :customer_phone, :merchant_id,
        :transaction_type, :parent_transaction_uuid
      )
    else
      params.permit(
        :amount, :customer_email, :customer_phone, :merchant_id,
        :transaction_type, :parent_transaction_uuid
      )
    end
  end
end
