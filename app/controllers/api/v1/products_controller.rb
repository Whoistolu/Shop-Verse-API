class Api::V1::ProductController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_brand_owner!

  def create
  
    product = current_user.owned_brand.products.new(product_params)

    if product.save
      render json: product, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_brand_owner!
    unless current_user.has_role?(:brand_owner)
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :status, :image_url, :category_id)
  end
end
