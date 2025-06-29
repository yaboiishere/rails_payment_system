class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :status, { inactive: 0, active: 1 }

  validates :name, :email, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  def admin?
    false
  end
end
