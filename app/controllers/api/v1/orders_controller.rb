class Api::V1::OrdersController < ApplicationController
     before_action :authenticate_user!

     def index
        orders = current_user.orders
        render json: orders
    end
end
