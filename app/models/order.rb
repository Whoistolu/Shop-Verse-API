class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items

  enum status: { pending: 0, processed: 1, shipped: 2, delivered: 3, cancelled: 4 }
end
