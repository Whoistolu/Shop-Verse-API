class Api::V1::Users::CustomRegistrationsController < ApplicationController
  respond_to :json
  # In API-only mode we don't have a global authenticate before_action, so don't raise if missing
  skip_before_action :authenticate_user!, only: [ :brand_signup, :customer_signup ], raise: false

  def brand_signup
    handle_signup("brand_owner", "Brand Owner Registration successful")
  end

  def customer_signup
    handle_signup("customer", "Customer Registration successful")
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end

  def handle_signup(role_name, success_message)
    user_role = UserRole.find_by(name: role_name)

    unless user_role
      render json: { error: "Role not found" }, status: :unprocessable_entity
      return
    end

    default_status =
    case role_name
    when "customer"
      "pending_registration"
    when "brand_owner"
      "awaiting_approval"
    else
      nil
    end

    user = User.new(sign_up_params.merge(user_role_id: user_role.id, status: default_status))

    if user.save
        if role_name == "customer"
            otp = OtpGenerator.generate_for(user)
            OtpMailer.send_otp(user, otp).deliver_now
        elsif role_name == "brand_owner"
            RegistrationMailer.pending_approval(user).deliver_later
        end


      UserMailer.welcome_email(user).deliver_later

      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

      render json: {
        message: success_message,
        user: {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          role_id: user.user_role_id,
          token: token
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
