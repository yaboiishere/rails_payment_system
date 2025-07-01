# frozen_string_literal: true

class Api::V1::TransactionController < Api::BaseController
  def create
    transaction_params
    return unless verify_merchant(transaction_params[:merchant_id])

    result = Transaction::Create.call(params: transaction_params)

    # any is used for the format so that it if no content type is specified,
    # it defaults to JSON. This allows the case where the body is passed as params and can't be parsed as JSON.
    # An example of this is when the request is made in Rspec with `post transaction_index_path, params: { transaction: { ... } }`
    # where the body is passed as params instead of JSON.
    respond_to do |format|
      if result.success?
        format.xml { render xml: result[:response], status: :created }
        format.any { render json: result[:response], status: :created }
      else
        errors = result[:errors] || "Failed to create transaction"
        format.xml { render xml: { errors: errors }, status: :unprocessable_entity }
        format.any { render json: { errors: errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:amount, :customer_email, :customer_phone, :merchant_id, :transaction_type, :parent_transaction_uuid)
  end
end
