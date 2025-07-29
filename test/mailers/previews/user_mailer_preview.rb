class UserMailerPreview < ActionMailer::Preview
  def otp_email
    user = User.first || User.new(email: "demo@shopverse.com")
    UserMailer.with(user: user, otp_code: "123456").otp_email
  end
end
