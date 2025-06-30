# frozen_string_literal: true

class MerchantPresenter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::OutputSafetyHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  attr_reader :merchant

  def initialize(merchant)
    @merchant = merchant
  end

  def name
    merchant.name
  end

  def email
    mail_to(merchant.email, merchant.email, class: "text-decoration-none")
  end

  def status_badge
    badge_class = merchant.active? ? "bg-success" : "bg-secondary"
    content_tag(:span, merchant.status.titleize, class: "badge #{badge_class}")
  end

  def total_sum
    number_to_currency(merchant.total_transaction_sum)
  end

  def created_at
    merchant.created_at.strftime("%Y-%m-%d %H:%M")
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
