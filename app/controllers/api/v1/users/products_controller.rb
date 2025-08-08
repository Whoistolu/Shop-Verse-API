class Api::V1::ProductController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_brand_owner, only: [:create, :index]
  before_action :set_product, only: [:update, :destroy, :show]
  respond_to :json

  def index
    @products = current_user.brand.products
    render json: @products
  end

  def create
    return render json: { error: "Invalid category" }, status: :unprocessable_entity unless Category.exists?(params[:product][:category_id])

    @product = current_user.brand.products.new(product_params.except(:brand_id))

    if @product.save
      render json: @product, status: :created
    else
      render json: { error: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    return render json: { error: "Invalid category" }, status: :unprocessable_entity unless Category.exists?(params[:product][:category_id])

    if @product.update(product_params.except(:brand_id))
      render json: { message: "Product updated successfully", product: @product }, status: :ok
    else
      render json: { error: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      render json: { message: "Product deleted successfully" }, status: :ok
    else
      render json: { error: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :category_id, :status, :stock, :image_url)
  end

  def ensure_brand_owner
    unless current_user.user_role.name == "brand_owner"
      render json: { error: "You are not authorized to perform this action" }, status: :forbidden
    end
  end

  def set_product
    @product = case current_user.user_role.name
               when "brand_owner"
                 current_user.brand.products.find_by(id: params[:id])
               when "customer"
                 Product
                   .joins(:brand)
                   .where(id: params[:id], status: "active", brands: { active: true })
                   .first
               when "super_admin"
                 Product.find_by(id: params[:id])
               end

    render json: { error: "Product not found or not accessible" }, status: :not_found unless @product
  end
end
