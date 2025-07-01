class Merchant::TransactionController < ApplicationController
  before_action :require_owner_or_admin, only: :show

  def show
    params.permit(:merchant_id, :uuid).require([ :merchant_id, :uuid ])
    @transaction_presenter = Transaction.find_by!(uuid: params[:uuid]).then { |t| TransactionPresenter.new(t) }
  end
end
