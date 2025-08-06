class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand

  enum status: { published: 0, unpublished: 1 }
end
