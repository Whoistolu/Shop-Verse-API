class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  belongs_to :user_role
  has_many :otps, dependent: :destroy

  validates :email, :first_name, :last_name, presence: true

  enum status: {
    pending_registration: "pending_registration",
    registered: "registered",
    suspended: "suspended",
    awaiting_approval: "awaiting_approval",
    approved: "approved",
    rejected: "rejected"
  }, _suffix: true 

  validates :status, presence: true

  # def super_admin?
  #   user_role.name == "super_admin"
  # end

  # def brand_owner?
  #   user_role.name == "brand_owner"
  # end

  # def customer?
  #  user_role.name == "customer"
  # end
end
