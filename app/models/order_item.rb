class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  enum status: { pending: 0,  processed: 1, shipped: 2, delivered: 3, cancelled: 4 }

   after_update :update_order_status

  private

  def update_order_status
    order.refresh_status!
  end
end
