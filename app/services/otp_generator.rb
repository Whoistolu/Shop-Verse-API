class OtpGenerator
    OTP_EXPIRATION_TIME = 10.minutes

    def def initialize(user)
        @user = user
    end

    def generate
        otp = rand(100_000..999_999).to_s

        @user.update!(
        otp_code: otp,
        otp_generated_at: Time.current
        )

        otp
    end
end