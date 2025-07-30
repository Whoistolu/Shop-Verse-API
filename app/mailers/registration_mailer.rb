class RegistrationMailer < ApplicationMailer
  default from: "no-reply@shopverse.com"

  def pending_approval(user)
    @user = user
    mail(to: @user.email, subject: "Your registration is pending approval")
  end
end
