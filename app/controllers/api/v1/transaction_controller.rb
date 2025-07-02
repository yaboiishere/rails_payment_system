# frozen_string_literal: true

class Api::V1::TransactionController < Api::BaseController
  def create
    return unless verify_merchant(transaction_params[:merchant_id])

    result = Transaction::Create.call(params: transaction_params)

    render_response(
      success: result.success?,
      data: result[:response],
      errors: { errors: (result[:errors] || "Failed to create transaction") },
      ok_status: :created,
      error_status: :unprocessable_entity)
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
