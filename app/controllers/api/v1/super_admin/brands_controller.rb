class Api::V1::SuperAdmin::BrandsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_super_admin
    respond_to :json

    def index
        brands = User.includes(:user_role).where(user_roles: { name: "brand_owner" })
        render json: brands, status: :ok
    end

    private

    def ensure_super_admin
        unless current_user.user_role.name == "super_admin"
            render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
    end
end
