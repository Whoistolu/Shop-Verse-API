class Api::V1::BrandsController < ApplicationController
  before_action :authenticate_user!, only: [ :dashboard, :orders, :update_order_status, :products, :create_product, :update_product, :delete_product, :update_product_stock, :update_product_status, :bulk_update_products ]
  before_action :authorize_brand_owner!, only: [ :dashboard, :orders, :update_order_status, :products, :create_product, :update_product, :delete_product, :update_product_stock, :update_product_status, :bulk_update_products ]
  before_action :ensure_brand_can_sell!, only: [ :create_product, :update_product ]
  before_action :set_product, only: [ :update_product, :delete_product, :update_product_stock, :update_product_status ]

  # Public endpoint for customers to view brands
  def index
    brands = Brand.includes(:user, :products)
    render json: brands.as_json(include: { user: { only: [ :first_name, :last_name ] }, products: { only: [ :id, :name, :price, :image_url ] } }), status: :ok
  end

  def show
    brand = Brand.includes(:user, :products).find(params[:id])
    render json: brand.as_json(include: {
      user: { only: [ :first_name, :last_name ] },
      products: { only: [ :id, :name, :description, :price, :stock, :image_url, :status ] }
    }), status: :ok
  end

  # Brand owner dashboard
  def dashboard
    brand = current_user.owned_brand

    metrics = {
      total_products: brand.products.count,
      published_products: brand.products.published.count,
      total_orders: brand.total_orders,
      total_sales: brand.total_sales,
      top_selling_products: brand.top_selling_products(5).as_json(only: [ :id, :name, :total_sold, :revenue ]),
      recent_orders: brand.recent_orders(10).as_json(include: {
        order_items: { include: :product },
        customer: { include: :user }
      })
    }

    render json: metrics, status: :ok
  end

  # Brand owner order management
  def orders
    brand = current_user.owned_brand

    orders = Order.joins(order_items: :product)
                  .where(products: { brand_id: brand.id })
                  .distinct
                  .includes(:order_items, :customer)
                  .order(created_at: :desc)

    # Filter by status if provided
    orders = orders.where(status: params[:status]) if params[:status].present?

    render json: orders.as_json(include: {
      order_items: { include: :product },
      customer: { include: :user }
    }), status: :ok
  end

  def update_order_status
    order = Order.joins(order_items: :product)
                 .where(products: { brand_id: current_user.owned_brand.id })
                 .find(params[:order_id])

    if order.update(status: params[:status])
      render json: { message: "Order status updated successfully", order: order }, status: :ok
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Brand owner product management
  def products
    brand = current_user.owned_brand
    products = brand.products.includes(:category)

    # Apply filters
    products = products.by_category(params[:category_id]) if params[:category_id].present?
    products = products.where(status: params[:status]) if params[:status].present?
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
        total_products: brand.products.count,
        published: brand.products.published.count,
        draft: brand.products.draft.count,
        archived: brand.products.archived.count,
        low_stock: brand.products.low_stock.count,
        out_of_stock: brand.products.out_of_stock.count
      }
    }, status: :ok
  end

  def create_product
    brand = current_user.owned_brand
    product = brand.products.new(product_params)

    if product.save
      render json: {
        message: "Product created successfully",
        product: product.as_json(include: :category)
      }, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_product
    if @product.update(product_params)
      render json: {
        message: "Product updated successfully",
        product: @product.as_json(include: :category)
      }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def delete_product
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

  def update_product_stock
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

  def update_product_status
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

  def bulk_update_products
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
      status = action == 'publish' ? 'published' : action
      if product.update(status: status)
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
    @product = current_user.owned_brand.products.find(params[:id])
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
