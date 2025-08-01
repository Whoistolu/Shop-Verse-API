class OtpGenerator
  EXPIRY = 10.minutes

  def self.generate_for(user)
    code = SecureRandom.random_number(1_000_000).to_s.rjust(6, "0")

    otp = user.otps.create!(
      code: code,
      expires_at: Time.current + EXPIRY
    )

    otp
  end
end
