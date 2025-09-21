class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show, :update_status ]

  # Customer endpoints
  def index
    authorize_customer!

    orders = current_user.customer_profile.orders.includes(:order_items, :customer)
    orders = orders.where(status: params[:status]) if params[:status].present?

    render json: orders.as_json(include: {
      order_items: { include: { product: { include: [ :brand, :category ] } } }
    }), status: :ok
  end

  def show
    if current_user.has_role?(:customer)
      authorize_customer!
      order = current_user.customer_profile.orders.find(params[:id])
    elsif current_user.has_role?(:brand_owner)
      authorize_brand_owner!
      order = Order.joins(order_items: :product)
                   .where(products: { brand_id: current_user.owned_brand.id })
                   .find(params[:id])
    end

    render json: order.as_json(include: {
      order_items: { include: { product: { include: [ :brand, :category ] } } },
      customer: { include: :user }
    }), status: :ok
  end

  def create
    authorize_customer!

    # Get cart from session
    cart = session[:cart] || {}

    if cart.empty?
      render json: { error: "Cart is empty" }, status: :unprocessable_entity
      return
    end

    # Calculate total
    total = calculate_order_total(cart)

    # Create order
    order = current_user.customer_profile.orders.new(order_params.merge(total_price: total))

    if order.save
      # Create order items
      cart.each do |product_id, quantity|
        product = Product.find(product_id)
        order.order_items.create!(
          product: product,
          quantity: quantity,
          unit_price: product.price
        )

        # Update product stock
        product.update!(stock: product.stock - quantity)
      end

      # Clear cart
      session[:cart] = {}

      render json: order.as_json(include: {
        order_items: { include: { product: { include: [ :brand, :category ] } } }
      }), status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    authorize_brand_owner!

    if @order.update(status: params[:status])
      render json: { message: "Order status updated successfully", order: @order }, status: :ok
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_customer!
    unless current_user.has_role?(:customer)
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end

  def authorize_brand_owner!
    unless current_user.has_role?(:brand_owner)
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end

  def set_order
    if current_user.has_role?(:brand_owner)
      @order = Order.joins(order_items: :product)
                    .where(products: { brand_id: current_user.owned_brand.id })
                    .find(params[:id])
    else
      @order = current_user.customer_profile.orders.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end

  def order_params
    params.require(:order).permit(
      :delivery_address,
      :delivery_phone_number,
      :delivery_recipient_name
    )
  end

  def calculate_order_total(cart)
    product_ids = cart.keys.map(&:to_i)
    products = Product.where(id: product_ids)

    products.sum do |product|
      product.price * cart[product.id.to_s].to_i
    end
  end
end
