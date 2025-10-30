class Brand < ApplicationRecord
  belongs_to :user
  belongs_to :status_changed_by, class_name: 'User', optional: true
  has_many :products, dependent: :destroy
  has_many :order_items, through: :products

  validates :name, presence: true
  validates :status, presence: true

  enum status: {
    pending: 0,
    active: 1,
    suspended: 2,
    deactivated: 3,
    rejected: 4
  }

  scope :operational, -> { where(status: [:active]) }
  scope :non_operational, -> { where(status: [:suspended, :deactivated, :rejected]) }

  before_validation :set_default_status, on: :create

  def activate!(admin_user)
    update!(
      status: 'active',
      activated_at: Time.current,
      status_changed_by: admin_user
    )
  end

  def deactivate!(admin_user, reason = nil)
    update!(
      status: 'deactivated',
      deactivated_at: Time.current,
      status_changed_by: admin_user
    )
    # Optionally deactivate all products
    products.update_all(status: 'inactive') if products.respond_to?(:update_all)
  end

  def suspend!(admin_user, reason = nil)
    update!(
      status: 'suspended',
      deactivated_at: Time.current,
      status_changed_by: admin_user
    )
  end

  def can_sell?
    active?
  end

  def operational?
    active?
  end

  def total_orders
    return 0 unless operational?
    order_items.joins(:order).distinct.count(:order_id)
  end

  def total_sales
    return 0 unless operational?
    order_items.sum { |item| item.quantity * item.unit_price }
  end

  def top_selling_products(limit = 5)
    return Product.none unless operational?
    products.joins(:order_items)
            .group("products.id")
            .order("SUM(order_items.quantity) DESC")
            .limit(limit)
  end

  def recent_orders(limit = 10)
    return Order.none unless operational?
    Order.joins(order_items: :product)
         .where(products: { brand_id: id })
         .distinct
         .order(created_at: :desc)
         .limit(limit)
  end

  def status_history
    {
      created_at: created_at,
      activated_at: activated_at,
      deactivated_at: deactivated_at,
      current_status: status,
      last_changed_by: status_changed_by&.email
    }
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
