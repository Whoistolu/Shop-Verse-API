class Api::V1::SuperAdmin::UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_super_admin

    private

    def ensure_super_admin
        unless current_user.user_role.name == "super_admin"
            render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
end
