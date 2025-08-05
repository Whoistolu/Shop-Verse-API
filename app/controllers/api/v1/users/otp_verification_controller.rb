class Api::V1::Users::OtpVerificationController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :verify_otp ]

    def verify_otp

       user = User.includes(:user_role).find_by(email: params[:email])

        if user.nil? || user.user_role.name != "customer"
            render json: { error: "Invalid user or role" }, status: :unprocessable_entity
            return
        end

        otp = user.otps.order(created_at: :desc).find_by(code: params[:otp])

        if otp.nil?
            return render json: { error: "Invalid OTP" }, status: :unauthorized
        end

        if otp.used?
            return render json: { error: "OTP already used" }, status: :unauthorized
        end

        otp.mark_as_used

        if otp.expires_at < Time.current
            return render json: { error: "OTP has expired" }, status: :unauthorized
        end



        case user.user_role.name
        when "customer"
            user.update(status: User.statuses[:registered])
        when "brand_owner"
            user.update(status: User.statuses[:approved])
        else
            render json: { error: "Unsupported user role" }, status: :unprocessable_entity
            return
        end

        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first


        render json: {
            message: "OTP verified successfully",
            token: token,
            user: {
                id: user.id,
                email: user.email
            }
        }, status: :ok
    end
end
