# frozen_string_literal: true

class MerchantForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :status, :string

  attr_reader :merchant

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: User::Merchant.statuses.keys }

  def initialize(merchant, params = {})
    @merchant = merchant
    super(params.presence || default_attributes)
  end

  def save
    return false unless valid?

    merchant.assign_attributes(email: email, status: status)
    merchant.save
  end

  private

  def default_attributes
    {
      email: merchant.email,
      status: merchant.status
    }
  end
end
