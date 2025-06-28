class Transaction < ApplicationRecord
  belongs_to :merchant, class_name: "User::Merchant", required: true
  belongs_to :parent_transaction, class_name: "Transaction", required: false

  enum :status, { approved: 0, reversed: 1, refunded: 2, error: 3 }

  validates :uuid, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  validates :amount, numericality: { greater_than: 0 }, unless: -> { self.is_a? Transaction::Reversal }
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :customer_phone, presence: true

  before_validation :generate_uuid, on: :create

  statuses.each do |status, _|
    define_method("is_#{status}?") do
      self.status == status.to_s
    end
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
