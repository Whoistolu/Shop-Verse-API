class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum status: {
    pending: "pending",
    processing: "processing",
    partially_shipped: "partially_shipped",
    shipped: "shipped",
    partially_delivered: "partially_delivered",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  validates :user_id, :total_price, :status, :delivery_address, :delivery_phone_number, :delivery_recipient_name, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
end
