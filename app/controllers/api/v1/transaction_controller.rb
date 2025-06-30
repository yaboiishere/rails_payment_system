# frozen_string_literal: true

class Api::V1::TransactionController < Api::BaseController
  def create
    return unless verify_merchant(params[:merchant_id])
    result = Transaction::Create.call(params: transaction_params)
    if result.success?
      render json: result[:response], status: :created
    else
      render json: { errors: result[:errors] || "Failed to create transaction" }, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.permit(:amount, :customer_email, :customer_phone, :merchant_id, :transaction_type, :parent_transaction_uuid)
  end
end
