class Api::V1::SuperAdmin::UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_super_admin
    before_action :set_user, only: [ :show, :update_status ]

    def index
        roles = params[:role].present? ? [ params[:role] ] : [ "customer", "brand_owner" ]

        users = User.includes(:user_role)
                    .where(user_roles: { name: roles })

        render json: users, status: :ok
    end

    def show
        render json: @user, status: :ok
    end

    def update_status
        status = params[:status].to_s

        unless User.statuses.key?(status)
            return render json: { error: "Invalid status value" }, status: :unprocessable_entity
        end

        if @user.update(status: status)
            render json: { message: "User status updated successfully" }, status: :ok
        else
            render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def metrics
        total_brands    = User.joins(:user_role).where(user_roles: { name: "brand_owner" }).count
        total_customers = User.joins(:user_role).where(user_roles: { name: "customer" }).count
        # total_orders    = Order.count

        render json: {
            brands: total_brands,
            customers: total_customers,
            orders: total_orders
        }, status: :ok
    end



  private

    def ensure_super_admin
        unless current_user.user_role.name == "super_admin"
        render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
    end

    def set_user
        @user = User.find_by(id: params[:id])
        render json: { error: "User not found" }, status: :not_found unless @user
    end
end
