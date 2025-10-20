class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :stock, :image_url, :status, :created_at, :updated_at

  belongs_to :brand
  belongs_to :category
end
