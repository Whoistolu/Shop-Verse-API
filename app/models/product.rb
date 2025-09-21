class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  has_many :order_items, dependent: :destroy

  validates :name, :description, :price, :stock, :status, :image_url, :category_id, :brand_id, presence: true
  validates :category_id, presence: true
  validates :price, :stock, numericality: { greater_than_or_equal_to: 0 }
  validate :category_must_be_global
  before_validation :set_default_status, on: :create

  scope :published, -> { where(status: :published) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) }
  scope :search, ->(query) { where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }

  def category_must_be_global
    unless Category.exists?(id: category_id)
      errors.add(:category_id, "must be valid")
    end
  end

  enum status: { 
    draft: 0, 
    published: 1, 
    archived: 2 
  }

  def total_sold
    order_items.sum(:quantity)
  end

  def revenue
    order_items.sum { |item| item.quantity * item.unit_price }
  end

  private

  def set_default_status
    self.status ||= :draft
  end
end
