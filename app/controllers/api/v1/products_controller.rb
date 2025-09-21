class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :update, :destroy, :update_stock, :update_status]

  # Public endpoints for customers
  def index
    products = Product.published.includes(:brand, :category)
    
    # Apply filters
    products = products.by_category(params[:category_id]) if params[:category_id].present?
    products = products.by_brand(params[:brand_id]) if params[:brand_id].present?
    products = products.search(params[:search]) if params[:search].present?
    
    # Pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    products = products.page(page).per(per_page)
    
    render json: {
      products: products.as_json(include: [:brand, :category]),
      pagination: {
        current_page: products.current_page,
        total_pages: products.total_pages,
        total_count: products.total_count
      }
    }, status: :ok
  end

  def show
    render json: @product.as_json(include: [:brand, :category]), status: :ok
  end

  # Brand owner endpoints
  def brand_products
    authorize_brand_owner!
    
    products = current_user.owned_brand.products.includes(:category)
    products = products.by_category(params[:category_id]) if params[:category_id].present?
    products = products.where(status: params[:status]) if params[:status].present?
    
    render json: products.as_json(include: :category), status: :ok
  end

  def create
    authorize_brand_owner!
    
    product = current_user.owned_brand.products.new(product_params)

    if product.save
      render json: product.as_json(include: :category), status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize_brand_owner!
    
    if @product.update(product_params)
      render json: { message: "Product updated successfully", product: @product.as_json(include: :category) }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_brand_owner!
    
    if @product.destroy
      render json: { message: "Product deleted successfully" }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_stock
    authorize_brand_owner!
    
    if @product.update(stock_params)
      render json: { message: "Stock updated successfully", product: @product }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    authorize_brand_owner!
    
    if @product.update(status_params)
      render json: { message: "Product status updated successfully", product: @product }, status: :ok
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

  def set_product
    if current_user.has_role?(:brand_owner)
      @product = current_user.owned_brand.products.find(params[:id])
    else
      @product = Product.published.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :status, :image_url, :category_id)
  end

  def stock_params
    params.require(:product).permit(:stock)
  end

  def status_params
    params.require(:product).permit(:status)
  end
end
