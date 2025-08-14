class Api::V1::CartsController < ApplicationController
    before_action :authenticate_user!

    def show
        render json: current_user.cart, include: :cart_items
    end

    def add_item
        cart = current_user.cart || current_user.create_cart
        product = Product.find(params[:product_id])
        cart.add_product(product, params[:quantity] || 1)
        render json: cart, include: :cart_items
    end
end
