class Brand < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  
  # Enums
  enum status: {
    pending: 0,
    active: 1,
    suspended: 2,
    rejected: 3
  }
  
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true, length: { minimum: 50, maximum: 1000 }
  validates :business_email, presence: true, uniqueness: true
  validates :business_phone, presence: true, uniqueness: true
  validates :business_address, presence: true
  validates :user_id, uniqueness: true # One brand per user
  validate :user_must_be_brand_owner
  
  # Scopes
  scope :active, -> { where(status: :active) }
  scope :pending_approval, -> { where(status: :pending) }
  
  # Instance methods
  def owner_name
    user.full_name
  end
  
  def can_sell?
    active?
  end
  
  def total_products
    products.count
  end
  
  def published_products_count
    products.where(status: 'published').count
  end
  
  def activate!
    update!(status: :active)
  end
  
  def suspend!
    update!(status: :suspended)
  end
  
  def reject!
    update!(status: :rejected)
  end
  
  private
  
  def user_must_be_brand_owner
    unless user&.brand_owner?
      errors.add(:user, 'must have brand_owner role')
    end
  end
end
