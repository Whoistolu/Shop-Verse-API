class Api::V1::BrandsController < ApplicationController
  before_action :authenticate_user!, only: [ :dashboard, :orders, :update_order_status ]
  # before_action :authorize_brand_owner!, only: [ :dashboard, :orders, :update_order_status ]

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

  private

  def authorize_brand_owner!
    unless current_user.has_role?(:brand_owner)
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end
end
