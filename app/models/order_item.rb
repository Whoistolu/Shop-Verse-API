class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  enum status: {
    pending: 0,
    processed: 1,
    shipped: 2,
    delivered: 3
  }
end
