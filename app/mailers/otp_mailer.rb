class OtpMailer < ApplicationMailer
    default from: "no-reply@shopverse.com"

    def send_otp(otp, user)
        @user = user
        @otp = otp
        mail(to: @user.email, subject: "Your OTP Code")
    end
end
