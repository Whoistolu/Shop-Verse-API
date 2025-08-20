class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_brand_owner!
  before_action :set_product, only: [:update_stock]
  

  def create
    product = current_user.owned_brand.products.new(product_params)

    if product.save
      render json: product, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_stock
    if @product.update(stock_params)
      render json: { message: "Stock updated successfully", product: @product }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_brand_owner!
    unless current_user.has_role?(:brand_owner)
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :status, :image_url, :category_id)
  end

  

  def set_product
    @product = current_user.owned_brand.products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found or not owned by your brand" }, status: :not_found
  end

  def stock_params
    params.require(:product).permit(:stock)
  end
end
