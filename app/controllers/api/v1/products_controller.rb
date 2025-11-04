class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_product, only: [ :show, :update, :destroy, :update_stock, :update_status ]

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
      products: products.as_json(include: [ :brand, :category ]),
      pagination: {
        current_page: products.current_page,
        total_pages: products.total_pages,
        total_count: products.total_count
      }
    }, status: :ok
  end

  def show
    render json: @product.as_json(include: [ :brand, :category ]), status: :ok
  end

  # Brand owner endpoints
  def brand_products
    authorize_brand_owner!

    products = current_user.owned_brand.products.includes(:category)
    products = products.by_category(params[:category_id]) if params[:category_id].present?
    products = products.where(status: params[:status]) if params[:status].present?

    # Search within brand products
    products = products.search(params[:search]) if params[:search].present?

    # Pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    products = products.page(page).per(per_page)

    render json: {
      products: products.as_json(include: :category),
      pagination: {
        current_page: products.current_page,
        total_pages: products.total_pages,
        total_count: products.total_count
      },
      summary: {
        total_products: current_user.owned_brand.products.count,
        published: current_user.owned_brand.products.published.count,
        draft: current_user.owned_brand.products.draft.count,
        archived: current_user.owned_brand.products.archived.count
      }
    }, status: :ok
  end

  def create
    authorize_brand_owner!
    ensure_brand_can_sell!

    product = current_user.owned_brand.products.new(product_params)

    if product.save
      render json: {
        message: "Product created successfully",
        product: product.as_json(include: :category)
      }, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize_brand_owner!
    ensure_brand_can_sell!

    if @product.update(product_params)
      render json: { 
        message: "Product updated successfully", 
        product: @product.as_json(include: :category) 
      }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_brand_owner!

    # Check if product has been ordered
    if @product.order_items.exists?
      # Archive instead of delete if product has order history
      if @product.update(status: 'archived')
        render json: { 
          message: "Product archived successfully (has order history)", 
          product: @product 
        }, status: :ok
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    else
      if @product.destroy
        render json: { message: "Product deleted successfully" }, status: :ok
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def update_stock
    authorize_brand_owner!

    if @product.update(stock_params)
      # Send low stock alert if applicable
      send_low_stock_alert if @product.stock <= 10
      
      render json: { 
        message: "Stock updated successfully", 
        product: @product,
        low_stock_warning: @product.stock <= 10
      }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    authorize_brand_owner!

    old_status = @product.status
    
    if @product.update(status_params)
      # Log status change
      Rails.logger.info "Brand #{current_user.owned_brand.name} changed product #{@product.name} status from #{old_status} to #{@product.status}"
      
      render json: { 
        message: "Product status updated successfully", 
        product: @product,
        previous_status: old_status
      }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bulk_update
    authorize_brand_owner!
    
    product_ids = params[:product_ids] || []
    action = params[:action]
    
    unless ['publish', 'archive', 'draft'].include?(action)
      return render json: { error: "Invalid bulk action" }, status: :unprocessable_entity
    end

    products = current_user.owned_brand.products.where(id: product_ids)
    
    if products.empty?
      return render json: { error: "No products found" }, status: :not_found
    end

    results = { success: [], failed: [] }

    products.each do |product|
      if product.update(status: action == 'publish' ? 'published' : action)
        results[:success] << {
          id: product.id,
          name: product.name,
          new_status: product.status
        }
      else
        results[:failed] << {
          id: product.id,
          name: product.name,
          errors: product.errors.full_messages
        }
      end
    end

    render json: {
      message: "Bulk action completed",
      action: action,
      results: results,
      summary: {
        total_processed: product_ids.count,
        successful: results[:success].count,
        failed: results[:failed].count
      }
    }
  end

  private

  def authorize_brand_owner!
    unless current_user.has_role?(:brand_owner)
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end

  def ensure_brand_can_sell!
    unless current_user.owned_brand.can_sell?
      render json: { 
        error: "Brand is not authorized to sell products", 
        brand_status: current_user.owned_brand.status 
      }, status: :forbidden and return
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

  def send_low_stock_alert
    # This could be expanded to send actual notifications
    Rails.logger.info "Low stock alert: Product #{@product.name} has #{@product.stock} items remaining"
    # TODO: Implement email notification or in-app notification system
  end
end
