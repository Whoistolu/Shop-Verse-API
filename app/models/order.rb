class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items

  enum status: {
    pending: 0,
    processed: 1,
    partly_shipped: 2,
    shipped: 3,
    partly_delivered: 4,
    delivered: 5,
    cancelled: 6
  }

end
