class MerchantController < ApplicationController
  before_action :require_admin, only: [ :index, :destroy ]
  before_action :require_owner_or_admin, only: [ :edit, :update, :show ]

  def index
    @merchant_presenters = User::Merchant.order(:email).map { |m| MerchantPresenter.new(m) }
  end

  def show
    params.permit(:id).require(:id)
    @merchant = User::Merchant.find(params[:id]).then { |m| MerchantPresenter.new(m) }
  end

  def destroy
    params.permit(:id).require(:id)
    @merchant = User::Merchant.find(params[:id])

    if @merchant.destroy
      redirect_to merchant_index_path, notice: "Merchant deleted successfully."
    else
      redirect_to merchant_index_path, alert: @merchant.errors.full_messages.to_sentence
    end
  end

  def edit
    @merchant = User::Merchant.find(params[:id])
    @form = MerchantForm.new(@merchant)
  end

  def update
    @merchant = User::Merchant.find(params[:id])
    @form = MerchantForm.new(@merchant, merchant_params)

    if @form.save
      redirect_to merchant_path(@merchant), notice: "Merchant updated successfully."
    else
      flash.now[:alert] = "Could not update merchant."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def merchant_params
    params.require(:merchant_form).permit(:email, :status)
  end
end
