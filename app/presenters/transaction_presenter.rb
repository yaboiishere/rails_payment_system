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

  def type_label
    transaction.type.demodulize
  end

  def amount
    transaction.amount.present? ? number_to_currency(transaction.amount) : "-"
  end

  def status_badge
    badge_class =
      case transaction.status
      when "approved" then "bg-success"
      when "error" then "bg-danger"
      else "bg-secondary"
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
      link_to(transaction.parent_transaction.uuid, "/transaction/#{transaction.parent_transaction.id}")
    else
      "-"
    end
  end
end
