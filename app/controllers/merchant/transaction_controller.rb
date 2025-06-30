class Merchant::TransactionController < ApplicationController
  before_action :require_owner_or_admin, only: :show

  def show
    params.permit(:merchant_id, :id).require([ :merchant_id, :id ])
    @transaction_presenter = Transaction.find(params[:id]).then { |t| TransactionPresenter.new(t) }
  end
end
