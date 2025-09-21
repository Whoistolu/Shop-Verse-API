class Api::V1::CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_customer!

  def show
    cart_items = get_cart_items
    total = calculate_cart_total(cart_items)
    
    render json: {
      items: cart_items,
      total: total,
      item_count: cart_items.sum { |item| item[:quantity] }
    }, status: :ok
  end

  def add_item
    product = Product.published.find(params[:product_id])
    quantity = params[:quantity].to_i
    
    if quantity <= 0
      render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity
      return
    end
    
    if quantity > product.stock
      render json: { error: "Not enough stock available" }, status: :unprocessable_entity
      return
    end

    cart = session[:cart] || {}
    cart_key = product.id.to_s
    
    if cart[cart_key]
      cart[cart_key] += quantity
    else
      cart[cart_key] = quantity
    end
    
    session[:cart] = cart
    
    render json: { 
      message: "Item added to cart successfully",
      cart: get_cart_summary
    }, status: :ok
  end

  def update_item
    product = Product.published.find(params[:product_id])
    quantity = params[:quantity].to_i
    
    if quantity < 0
      render json: { error: "Quantity cannot be negative" }, status: :unprocessable_entity
      return
    end
    
    cart = session[:cart] || {}
    cart_key = product.id.to_s
    
    if quantity == 0
      cart.delete(cart_key)
    else
      if quantity > product.stock
        render json: { error: "Not enough stock available" }, status: :unprocessable_entity
        return
      end
      cart[cart_key] = quantity
    end
    
    session[:cart] = cart
    
    render json: { 
      message: "Cart updated successfully",
      cart: get_cart_summary
    }, status: :ok
  end

  def remove_item
    product = Product.published.find(params[:product_id])
    cart = session[:cart] || {}
    cart.delete(product.id.to_s)
    session[:cart] = cart
    
    render json: { 
      message: "Item removed from cart successfully",
      cart: get_cart_summary
    }, status: :ok
  end

  def clear
    session[:cart] = {}
    render json: { message: "Cart cleared successfully" }, status: :ok
  end

  private

  def authorize_customer!
    unless current_user.has_role?(:customer)
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end

  def get_cart_items
    cart = session[:cart] || {}
    product_ids = cart.keys.map(&:to_i)
    
    products = Product.published.where(id: product_ids).includes(:brand, :category)
    
    products.map do |product|
      {
        product: product.as_json(include: [:brand, :category]),
        quantity: cart[product.id.to_s].to_i,
        subtotal: product.price * cart[product.id.to_s].to_i
      }
    end
  end

  def calculate_cart_total(cart_items)
    cart_items.sum { |item| item[:subtotal] }
  end

  def get_cart_summary
    cart_items = get_cart_items
    {
      items: cart_items,
      total: calculate_cart_total(cart_items),
      item_count: cart_items.sum { |item| item[:quantity] }
    }
  end
end
