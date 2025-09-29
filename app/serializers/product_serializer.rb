class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :stock_quantity, :image_url, :is_published, :created_at, :updated_at

  belongs_to :brand
  belongs_to :category
end
