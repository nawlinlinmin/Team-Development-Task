class ChangeLeaderMailer < ApplicationMailer

  def appointment_mail(email, team_name)
    @email = email
    @team_name = team_name
    mail to: @email, subject: 'チームの新しいリーダーに任命されました'
  end
end
