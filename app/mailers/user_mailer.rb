class UserMailer < ActionMailer::Base
  default from: "api@mashup.com"

  def password_reset(user, password)
    @user = user
    @password = password

    mail to: user.email, subject: "Your api password"
  end

end
