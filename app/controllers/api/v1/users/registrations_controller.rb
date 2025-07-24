class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
    respond_to :json
    skip_before_action :authenticate_user!, only: [:create]

    def create
        build_resource(sign_up_params)

        resource.save

        if resource.persisted?
            token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first

            render json: {
                message: "Registration successful",
                user: {
                    id: resource.id,
                    email: resource.email,
                    first_name: resource.first_name,
                    last_name: resource.last_name,
                    role_id: resource.user_role_id
                }
            }, status: :created
        else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def sign_up_params
        params.require(:user).permit(:email, :password, :passsword_confirmation, :first_name, :last_name, :user_role_id)
    end

    def account_update_params
        params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :first_name, :last_name, :user_role_id)
    end
end
