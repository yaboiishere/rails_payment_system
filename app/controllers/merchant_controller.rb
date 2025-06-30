class MerchantController < ApplicationController
  include Permission
  before_action :require_admin, only: :index
  before_action :require_owner_or_admin, only: :show

  def index
    @merchant_presenters = User::Merchant.order(:email).map { |m| MerchantPresenter.new(m) }
  end

  def show
    params.permit(:id).require(:id)
    @merchant = User::Merchant.find(params[:id]).then { |m| MerchantPresenter.new(m) }
  end
end
