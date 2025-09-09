class Api::V1::OrdersController < ApplicationController
    #customer side
    def show
        order = current_user.orders.find(params[:id])
        render json: order.as_json(include: { order_items: { include: :product } })
    end

    def create
        order = current_user.orders.new(order_params)

        if order.save
        render json: order, status: :created
        else
        render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
        end
    end


    private

    def authorize_customer!
        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.has_role?(:customer)
    end

    def order_params
        params.require(:order).permit(
        :delivery_address,
        :delivery_phone_number,
        :delivery_recipient_name,
        order_items_attributes: [:product_id, :quantity]
        )
    end
end
