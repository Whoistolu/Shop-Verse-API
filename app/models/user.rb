class User < ApplicationRecord
  has_secure_password
  
  # Associations
  has_one :brand, dependent: :destroy
  has_one :customer, dependent: :destroy
  
  # Enums
  enum role: {
    customer: 0,
    brand_owner: 1,
    super_admin: 2
  }
  
  enum status: {
    active: 0,
    inactive: 1,
    suspended: 2
  }
  
  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :role, presence: true
  
  # Callbacks
  before_validation :downcase_email
  after_create :create_role_specific_record
  
  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_role, ->(role) { where(role: role) }
  
  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def email_verified?
    email_verified_at.present?
  end
  
  def has_role?(role_name)
    role.to_s == role_name.to_s
  end
  
  def can_access_admin?
    super_admin?
  end
  
  def owned_brand
    brand if brand_owner?
  end
  
  def customer_profile
    customer if customer?
  end
  
  private
  
  def downcase_email
    self.email = email&.downcase
  end
  
  def create_role_specific_record
    case role
    when 'customer'
      create_customer!
    when 'brand_owner'
      # Brand will be created separately when approved
    end
  end
end
