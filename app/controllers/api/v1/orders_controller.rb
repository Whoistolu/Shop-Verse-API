class Api::V1::OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_brand_owner!

    def index
        orders = Order.joins(:order_items)
                    .where(order_items: { product_id: current_user.owned_brand.product_ids })
                    .distinct

        render json: orders.as_json(include: {
        order_items: { include: :product },
        customer: { only: [:id, :email] }
        })
    end

    def update_item_status
        order_item = OrderItem.joins(:product)
                            .where(products: { brand_id: current_user.owned_brand.id })
                            .find(params[:id])

        if order_item.update(status: params[:status])
        render json: { message: "Order item updated successfully", order: order_item.order }, status: :ok
        else
        render json: { errors: order_item.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def authorize_brand_owner!
        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.has_role?(:brand_owner)
    end
end

