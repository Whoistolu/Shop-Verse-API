class Api::V1::OrdersController < ApplicationController
     before_action :authenticate_user!

     def index
        orders = current_user.orders
        render json: orders
    end

     def show
        order = current_user.orders.find(params[:id])
        render json: order
    end
end
