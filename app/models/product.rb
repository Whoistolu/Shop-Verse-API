class Product < ApplicationRecord
  belongs_to :brand
  belongs_to :category

  enum status: { published: "published", unpublished: "unpublished" }

  validates :name, :price, :stock, :status, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
