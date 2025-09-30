class Api::V1::Users::CustomSessionsController < ApplicationController
  respond_to :json

  def brand_login
    handle_login("brand_owner", "Login successful")
  end

  def customer_login
    handle_login("customer", "Login successful")
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def handle_login(role_name, success_message)
    user_role = UserRole.find_by(name: role_name)

    unless user_role
      render json: { error: "Role not found" }, status: :unprocessable_entity
      return
    end

    user = User.find_by(email: login_params[:email], user_role_id: user_role.id)

    # Check if user exists and password is valid
    unless user&.valid_password?(login_params[:password])
      render json: { error: "Invalid credentials" }, status: :unauthorized
      return
    end

    # Check if user is approved or registered (for brand_owner or customer)
    if user.brand_owner? && user.status != "approved"
      render json: { error: "Brand owner account not approved yet" }, status: :unauthorized
      return
    elsif user.customer? && user.status != "registered"
      render json: { error: "Customer account not registered yet" }, status: :unauthorized
      return
    end

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
    }, status: :ok
  end
end
