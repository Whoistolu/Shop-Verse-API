class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  has_many :order_items, dependent: :destroy

  validates :name, :description, :price, :stock, :status, :image_url, :category_id, :brand_id, presence: true
  validates :category_id, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :name, length: { minimum: 3, maximum: 100 }
  validates :description, length: { minimum: 10, maximum: 1000 }
  validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }
  
  validate :category_must_be_global
  validate :brand_must_be_active
  before_validation :set_default_status, on: :create

  scope :published, -> { where(status: :published) }
  scope :available, -> { published.where('stock > 0') }
  scope :low_stock, -> { where('stock <= 10 AND stock > 0') }
  scope :out_of_stock, -> { where(stock: 0) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) }
  scope :search, ->(query) { where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }
  scope :price_range, ->(min, max) { where(price: min..max) }

  def category_must_be_global
    unless Category.exists?(id: category_id)
      errors.add(:category_id, "must be valid")
    end
  end

  def brand_must_be_active
    return unless brand_id.present?
    
    unless brand&.can_sell?
      errors.add(:brand, "must be active to create products")
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

  def available?
    published? && stock > 0
  end

  def low_stock?
    stock <= 10 && stock > 0
  end

  def out_of_stock?
    stock == 0
  end

  def can_be_ordered?
    published? && stock > 0 && brand.can_sell?
  end

  def decrease_stock!(quantity)
    if stock >= quantity
      decrement!(:stock, quantity)
    else
      errors.add(:stock, "Insufficient stock available")
      false
    end
  end

  def increase_stock!(quantity)
    increment!(:stock, quantity)
  end

  def popularity_score
    # Simple popularity calculation based on total sold
    total_sold * 0.3 + (revenue / 100) * 0.7
  end

  def self.popular(limit = 10)
    joins(:order_items)
      .group('products.id')
      .order('SUM(order_items.quantity) DESC')
      .limit(limit)
  end

  def self.trending(days = 30)
    joins(:order_items)
      .joins('JOIN orders ON order_items.order_id = orders.id')
      .where('orders.created_at >= ?', days.days.ago)
      .group('products.id')
      .order('SUM(order_items.quantity) DESC')
  end

  private

  def set_default_status
    self.status ||= :draft
  end
end
