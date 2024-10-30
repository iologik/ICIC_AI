# frozen_string_literal: true

class UpdateMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  def email_sub_investor(update, admin_user)
    @update = update
    @admin_user = admin_user

    subject = "New Update for #{@update.investment.name}"
    if Rails.env.production?
      mail(to: @admin_user.email, subject: subject, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    else
      mail(subject: subject, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    end
  end
end
