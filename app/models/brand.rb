class Brand < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :order_items, through: :products

  validates :name, presence: true

  def total_orders
    order_items.joins(:order).distinct.count(:order_id)
  end

  def total_sales
    order_items.sum { |item| item.quantity * item.unit_price }
  end

  def top_selling_products(limit = 5)
    products.joins(:order_items)
            .group("products.id")
            .order("SUM(order_items.quantity) DESC")
            .limit(limit)
  end

  def recent_orders(limit = 10)
    Order.joins(order_items: :product)
         .where(products: { brand_id: id })
         .distinct
         .order(created_at: :desc)
         .limit(limit)
  end
end
