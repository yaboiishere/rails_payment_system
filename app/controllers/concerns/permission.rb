# frozen_string_literal: true

module Permission
  extend ActiveSupport::Concern

  def require_admin
    unless Current.user.admin?
      redirect_to merchant_path(Current.user), flash: { alert: "Access denied." }
    end
  end

  def require_owner_or_admin
    user = User.find_by(id: params[:id])
    unless user && user == Current.user || Current.user.admin?
      redirect_to merchant_path(Current.user), alert: "Access denied."
    end
  end
end
