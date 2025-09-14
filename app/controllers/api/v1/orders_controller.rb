class Api::V1::OrdersController < ApplicationController
    #customer side
    def index
        orders = current_user.orders.includes(:order_items, :customer)
        render json: orders.as_json(include: { order_items: { include: :product } })
    end

    def show
        order = current_user.orders.find(params[:id])
        render json: order.as_json(include: { order_items: { include: :product } })
    end

    
end
