# frozen_string_literal: true

class Transaction::Create < Trailblazer::Operation
  step :fetch_merchant
  step :validate_transaction_type
  step :call_transaction_operation
  step :format_response

  def fetch_merchant(ctx, params:, **)
    merchant_id = params[:merchant_id]
    ctx[:merchant] = User::Merchant.find_by(id: merchant_id)

    if ctx[:merchant].nil?
      # This is unreachable code, because the jwt authentication layer should prevent this from happening.
      ctx[:errors] ||= []
      ctx[:errors] << "Merchant does not exist"
      false
    else
      true
    end
  end

  def validate_transaction_type(ctx, params:, **)
    transaction_type = params[:transaction_type]
    valid_types = %w[authorize charge refund reversal]

    unless valid_types.include?(transaction_type)
      ctx[:errors] ||= []
      ctx[:errors] << "Invalid transaction type #{transaction_type}. Valid types are: #{valid_types.join(', ')}"
      return false
    end

    true
  end

  def call_transaction_operation(ctx, params:, **)
    transaction_type = params[:transaction_type]
    operation_class = "Transaction::Operation::#{transaction_type.camelize}".constantize

    result = operation_class.call(merchant: ctx[:merchant], params: params)
    if result.success?
      ctx[:model] = result[:model]
      true
    else
      ctx[:errors] ||= []
      ctx[:errors].concat(result[:errors]) if result[:errors].present?
      false
    end
  end

  def format_response(ctx, **)
    ctx[:response] = {
      uuid: ctx[:model].uuid,
      parent_transaction_uuid: ctx[:model].parent_transaction&.uuid,
      type: ctx[:model].class.name.demodulize.downcase,
      amount: ctx[:model].amount,
      status: ctx[:model].status,
      customer_email: ctx[:model].customer_email,
      customer_phone: ctx[:model].customer_phone,
      merchant_id: ctx[:model].merchant_id,
      created_at: ctx[:model].created_at
    }
    true
  end
end
