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

  def refresh_status!
    if order_items.all?(&:cancelled?)
      update!(status: :cancelled)
    elsif order_items.all?(&:delivered?)
      update!(status: :delivered)
    elsif order_items.all? { |item| item.shipped? || item.delivered? }
      update!(status: :shipped)
    elsif order_items.any?(&:shipped?)
      update!(status: :partly_shipped)
    elsif order_items.any?(&:delivered?)
      update!(status: :partly_delivered)
    elsif order_items.all?(&:processed?)
      update!(status: :processed)
    else
      update!(status: :pending)
    end
  end
end
