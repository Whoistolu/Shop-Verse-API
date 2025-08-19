class Api::V1::ProductController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_brand_owner!
  validates :category_id, presence: true
  validate :category_must_be_global

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
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :status, :image_url, :category_id)
  end

  def category_must_be_global
    raise "is invalid" unless Category.exists?(id: category_id)
  end

  def set_product
    @product = current_user.owned_brand.products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found or not owned by your brand" }, status: :not_found
  end
end
