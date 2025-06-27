class User < ApplicationRecord
  enum :status, { inactive: 0, active: 1 }

  validates :name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  def admin?
    false
  end
end
