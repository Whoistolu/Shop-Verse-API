class OtpMailer < ApplicationMailer
    default from: "no-reply@shopverse.com"

    def send_otp(user, otp)
       @user = user
       @otp = otp.code
        mail(to: @user.email, subject: "Your OTP Code")
    end
end
