# frozen_string_literal: true

module Transaction::Operation::Shared
  extend ActiveSupport::Concern

  def validate_merchant(ctx, merchant:, **)
    return true if merchant.active?
    ctx[:errors] ||= []
    ctx[:errors] << "Merchant is not active"
    false
  end

  def validate_amount(ctx, params:, **)
    amount = params[:amount].to_d
    if amount <= 0
      ctx[:errors] ||= []
      ctx[:errors] << "Amount must be greater than zero"
      false
    else
      true
    end
  end

  def validate_customer(ctx, params:, **)
    email = params[:customer_email]
    phone = params[:customer_phone]
    # TODO: validate phone format if needed

    ctx[:errors] ||= []
    if email.blank? || phone.blank?
      ctx[:errors] << "Customer email and phone are required"
      false
    elsif !URI::MailTo::EMAIL_REGEXP.match?(email)
      ctx[:errors] << "Invalid email format"
      false
    else
      true
    end
  end

  def set_parent_transaction(ctx, params:, **)
    parent_transaction_uuid = params[:parent_transaction_uuid]
    if parent_transaction_uuid.nil?
      ctx[:errors] ||= []
      ctx[:errors] << "parent_transaction_uuid is missing"
      false
    else
      parent_transaction = Transaction.find_by(uuid: parent_transaction_uuid)
      if parent_transaction.present?
        ctx[:parent_transaction] = parent_transaction
        true
      else
        ctx[:errors] ||= []
        ctx[:errors] << "Parent transaction not found"
        false
      end
    end
  end

  def is_parent_approved?(ctx, parent_transaction:, **)
    if parent_transaction.is_approved?
      true
    else
      ctx[:errors] ||= []
      ctx[:errors] << "Parent transaction must be approved"
      false
    end
  end

  def persist(ctx, transaction:, **)
    if transaction.save
      ctx[:model] = transaction
      true
    else
      ctx[:errors] ||= []
      ctx[:errors] = transaction.errors.full_messages
      false
    end
  end

  def persist_failed_transaction(ctx, merchant:, params:, **)
    type = ctx[:tx_type]
    error_text = ctx[:errors]&.join(", ")

    transaction = type.create(
      merchant: merchant,
      parent_transaction: ctx[:parent_transaction],
      amount: params[:amount],
      status: "error",
      customer_email: params[:customer_email],
      customer_phone: params[:customer_phone],
      error_message: error_text
    )

    transaction.save(validate: false)

    ctx[:transaction] = transaction
    false
  end
end
