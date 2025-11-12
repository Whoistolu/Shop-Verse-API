class User < ApplicationRecord
  belongs_to :user_role
  has_secure_password

  enum status: { pending: "pending", active: "active", inactive: "inactive" }

  validates :first_name, :last_name, :email, :status, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
