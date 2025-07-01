# frozen_string_literal: true

class Api::V1::TransactionController < Api::BaseController
  def create
    return unless verify_merchant(transaction_params[:merchant_id])

    result = Transaction::Create.call(params: transaction_params)

    if result.success?
      if is_xml?
        render xml: result[:response], status: :created
      else
        render json: result[:response], status: :created
      end

    else
      errors = result[:errors] || "Failed to create transaction"
      if is_xml?
        render xml: { errors: errors }, status: :unprocessable_entity
      else
        render json: { errors: errors }, status: :unprocessable_entity
      end
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
