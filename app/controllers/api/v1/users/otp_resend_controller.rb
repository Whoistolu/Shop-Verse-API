class Api::V1::Users::OtpResendController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :resend ]

  def resend
    user = User.includes(:user_role).find_by(email: params[:email])

    if user.nil? || user.user_role.name != "customer"
      return render json: { error: "User not found" }, status: :unprocessable_entity
    end

    if user.status != "pending_registration"
      return render json: { error: "You are not eligible to request a new OTP" }, status: :forbidden
    end

    latest_otp = user.otps.order(created_at: :desc).first

    if latest_otp && latest_otp.expires_at > Time.current
      return render json: { error: "Your current OTP is still valid, kindly check your email for the OTP." }, status: :forbidden
    end

    new_otp = otp = OtpGenerator.generate_for(user)
    OtpMailer.send_otp(user, otp).deliver_now


    render json: {
      message: "New OTP sent successfully",
      otp_expires_at: new_otp.expires_at
    }, status: :ok
  end
end
