class OtpGenerator
  OTP_LENGTH = 6
  OTP_EXPIRY = 10.minutes

  def self.generate_for(user)
    code = rand.to_s[2..(1 + OTP_LENGTH)]
    user.update!(
      otp_code: code,
      otp_generated_at: Time.current
    )
    code
  end
end
