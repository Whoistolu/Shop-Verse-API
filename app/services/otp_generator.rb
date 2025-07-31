class OtpGenerator
  EXPIRY = 10.minutes

  def self.generate_for(user)
    code = rand.to_s[2..7]

    otp = user.otps.create!(
      code: code,
      expires_at: Time.current + EXPIRY
    )

    otp
  end
end
