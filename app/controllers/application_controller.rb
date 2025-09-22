class ApplicationController < ActionController::API
    include Devise::Controllers::Helpers
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def authenticate_user!
        unless warden.authenticate(scope: :user)
            render json: { error: "Unauthorized" }, status: :unauthorized
        end
    end

    def current_user
        @current_user ||= warden.user(:user)
    end

    def user_not_authorized(exception)
        render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
end
