class User < ApplicationRecord
  has_secure_password
  validate :password_complexity, on: :create
  has_many :sessions, dependent: :destroy

  enum :status, { inactive: 0, active: 1 }

  validates :name, :email, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  def admin?
    false
  end

  private

  def password_complexity
    if password.present? and !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, one digit, and needs to be minimum 8 characters."
    end
  end
end
