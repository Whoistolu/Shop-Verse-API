class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  validates :name, :description, :price, :stock, :status, :image_url, :category_id, :brand_id, presence: true

  enum status: { published: 0, unpublished: 1 }
end
