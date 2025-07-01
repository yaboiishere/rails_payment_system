# frozen_string_literal: true

module Permission
  extend ActiveSupport::Concern

  def require_admin
    unless Current.user.admin?
      redirect_to merchant_path(Current.user), flash: { alert: "Access denied." }
    end
  end

  def require_owner_or_admin
    return if Current.user.admin?

    authorized =
      # Transaction context: check if the transaction belongs to the merchant
      if params[:merchant_id]
        Transaction.exists?(uuid: params[:uuid], merchant_id: Current.user.id)
      elsif params[:id]
        # Merchant context: check self
        Current.user.id.to_s == params[:id].to_s
      else
        false
      end

    unless authorized
      redirect_to merchant_path(Current.user), alert: "Access denied."
    end
  end
end
