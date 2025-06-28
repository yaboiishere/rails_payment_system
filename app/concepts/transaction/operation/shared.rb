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

  def set_parent_transaction(ctx, tx_type:, params:, **)
    parent_transaction_uuid = params[:parent_transaction_uuid]
    if tx_type == :authorize && parent_transaction_uuid.present?
      ctx[:errors] ||= []
      ctx[:errors] << "Parent transaction uuid should not be present for authorize transactions"
      false
    elsif parent_transaction_uuid.present?
      parent_transaction = Transaction.find_by(uuid: parent_transaction_uuid)
      if parent_transaction
        ctx[:parent_transaction] = parent_transaction
        true
      else
        ctx[:errors] ||= []
        ctx[:errors] << "Parent transaction not found"
        false
      end
    else
      ctx[:parent_transaction] = nil
      true
    end
  end

  def validate_parent_transaction(ctx, tx_type:, parent_transaction:, params:, **)
    amount = params[:amount].to_d
    ctx[:errors] ||= []
    case tx_type
    when :authorize
      return true if parent_transaction.nil?

      # This should not happen due to the set_parent_transaction step, but it's left in just in case
      ctx[:errors] << "Parent transaction should not be present for authorize transactions"
      false
    when :charge
      if parent_transaction.is_a?(Transaction::Authorize) && parent_transaction.is_approved?
        # TODO: check if the amount should be the same as in the authorize transaction or just lower or equal to
        if parent_transaction.amount == amount
          true
        else
          ctx[:errors] << "Amount must be the same as the authorize transaction amount"
          false
        end
      else
        ctx[:errors] << "Parent transaction must be an authorize transaction"
        false
      end
    when :refund
      if parent_transaction.is_a?(Transaction::Charge) && parent_transaction.is_approved?
        # TODO: check if there can be partial refunds
        if parent_transaction.amount == amount
          true
        else
          ctx[:errors] << "Amount must be the same as the charge transaction amount"
          false
        end
      else
        ctx[:errors] << "Parent transaction must be a charge transaction"
        false
      end
    when :reversal
      if parent_transaction.is_a?(Transaction::Authorize) && parent_transaction.is_approved?
        true
      else

        ctx[:errors] << "Parent transaction must be an authorize transaction"
        false
      end
    else
      ctx[:errors] << "Unknown transaction type"
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

  def update_merchant_total(ctx, model:, **)
    ctx[:errors] ||= []
    if model.is_a?(Transaction) && model.is_approved?
      if model.is_a? Transaction::Charge
        if model.merchant.increment(:total_transaction_sum, model.amount).save
          return true
        else
          ctx[:errors] << "Failed to update merchant total"
          return false
        end
      elsif model.is_a?(Transaction::Refund)
        if model.merchant.decrement(:total_transaction_sum, model.amount).save
          return true
        else
          ctx[:errors] << "Failed to update merchant total"
          return false
        end
      end
    end
    ctx[:errors] << "Transaction is not charge or refund"
    false
  end
end
