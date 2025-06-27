# frozen_string_literal: true

module TransactionHelper
  def status_badge_class(status)
    {
      "approved" => "success",
      "refunded" => "warning",
      "reversed" => "secondary",
      "error" => "danger"
    }[status] || "light"
  end
end
