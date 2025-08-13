class Api::V1::CartsController < ApplicationController
    before_action :authenticate_user!

    def show
        render json: current_user.cart, include: :cart_items
    end
end
