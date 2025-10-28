class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  belongs_to :user_role
  has_many :otps, dependent: :destroy
  has_one :brand, dependent: :destroy
  has_one :customer, dependent: :destroy
  has_many :orders, through: :customer

  validates :email, :first_name, :last_name, presence: true

  def brand_owner?
    user_role.name == "brand_owner"
  end

  def customer?
    user_role.name == "customer"
  end

  def super_admin?
    user_role.name == "super_admin"
  end

  def has_role?(role_name)
    user_role.name == role_name.to_s
  end

  def owned_brand
      raise "Not a brand owner" unless brand_owner?
      brand
  end

  def customer_profile
    raise "Not a customer" unless customer?
    customer
  end

  enum status: {
    pending_registration: 0,
    registered: 1,
    suspended: 2,
    awaiting_approval: 3,
    approved: 4,
    rejected: 5
  }

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
  before_validation :set_default_status, on: :create

  private

  def set_default_status
    return if status.present? || user_role.nil?

    case user_role.name
    when "customer"
      self.status = "pending_registration"
    when "brand_owner"
      self.status = "awaiting_approval"
    end
  end
end
