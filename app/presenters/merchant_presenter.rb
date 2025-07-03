# frozen_string_literal: true

class MerchantPresenter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::OutputSafetyHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include LocalTimeHelper
  attr_reader :merchant

  def initialize(merchant)
    @merchant = merchant
  end

  def id
    merchant.id
  end

  def name
    merchant.name
  end

  def email
    mail_to(merchant.email, merchant.email, class: "text-decoration-none")
  end

  def description
    merchant.description.presence || "No description provided"
  end

  def status_badge
    badge_class = merchant.active? ? "bg-success" : "bg-secondary"
    content_tag(:span, merchant.status.titleize, class: "badge #{badge_class}")
  end

  def total_sum
    number_to_currency(merchant.total_transaction_sum)
  end

  def created_at
    local_time(merchant.created_at)
  end

  def link
    merchant_path(merchant)
  end

  def transactions
    merchant.transactions.order(created_at: :desc).map { |t| TransactionPresenter.new(t) }
  end

  def transactions_total
    transactions.count
  end
end
