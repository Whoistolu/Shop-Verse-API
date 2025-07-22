class ApplicationController < ActionController::API
    include Pundit

    before_action :authenticate_user!

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized(exception)
        render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
end
