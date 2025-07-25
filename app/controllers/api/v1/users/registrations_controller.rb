class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
    respond_to :json
    skip_before_action :authenticate_user!, only: [ :brand_signup, :customer_signup ]

    def brand_signup
        handle_signup("brand_owner", "Brand Owner Registration successful")
    end

    def customer_signup
        handle_signup("customer", "Customer Registration successful")
    end

    private

    def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :user_role_id)
    end

    def account_update_params
        params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :first_name, :last_name, :user_role_id)
    end
    

     def handle_signup(role_name, success_message)
      

        user_role = UserRole.find_by(name: role_name)

        unless user_role
            render json: { error: "Role not found" }, status: :unprocessable_entity
            return
        end

        build_resource(sign_up_params.merge(user_role_id: user_role.id))

        resource.save

        if resource.persisted?
            token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first

            render json: {
                message: success_message,
                user: {
                    id: resource.id,
                    email: resource.email,
                    first_name: resource.first_name,
                    last_name: resource.last_name,
                    role_id: resource.user_role_id,
                    token: token
                }
            }, status: :created
        else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
    end
end
