# frozen_string_literal: true

class TransactionPresenter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::OutputSafetyHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attr_reader :transaction

  def initialize(transaction)
    @transaction = transaction
  end

  def uuid
    transaction.uuid
  end

  def link
    merchant_transaction_path(transaction.merchant, transaction)
  end

  def type_label
    transaction.type.demodulize
  end

  def type_label_badge
    case transaction.type.demodulize
    when "Authorize"
      badge("Authorize", "info")
    when "Charge"
      badge("Charge", "primary")
    when "Refund"
      badge("Refund", "warning")
    when "Reversal"
      badge("Reversal", "secondary")
    else
      badge("Unknown", "dark")
    end
  end

  def amount
    transaction.amount.present? ? number_to_currency(transaction.amount) : "-"
  end

  def status_badge
    badge_class =
      case transaction.status
      when "approved" then "bg-success"
      when "error" then "bg-danger"
      when "refunded" then "bg-warning"
      when "reversed" then "bg-secondary"
      else "bg-secondary"
        # Unreachable code, but included for completeness
      end

    content_tag(:span, transaction.status.titleize, class: "badge #{badge_class}")
  end

  def customer_email
    transaction.customer_email
  end

  def customer_phone
    transaction.customer_phone
  end

  def created_at
    transaction.created_at.strftime("%Y-%m-%d %H:%M")
  end

  def parent_uuid_link
    if transaction.parent_transaction
      link_to(transaction.parent_transaction.uuid, merchant_transaction_path(transaction.merchant, transaction.parent_transaction), class: "text-decoration-none")
    else
      "-"
    end
  end

  def merchant_link
    link_to(transaction.merchant.name, merchant_path(transaction.merchant), class: "text-decoration-none")
  end

  def ancestry_chain
    chain = []
    current = transaction
    while current
      chain << TransactionPresenter.new(current)
      current = current.parent_transaction
    end
    chain.reverse
  end

  private

  def badge(text, style)
    content_tag(:span, text, class: "badge bg-#{style}")
  end
end
