class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :user_role
  has_many :delivery_addresses
  has_many :orders

  enum status: { pending: "pending", active: "active", inactive: "inactive" }

  validates :first_name, :last_name, :email, :status, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
