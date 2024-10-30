# frozen_string_literal: true

class SubInvestorMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  def investments_email(admin_user, file_name)
    attachments["#{file_name}.pdf"] = File.read("#{file_name}.pdf")
    if Rails.env.production?
      mail(subject: file_name, to: admin_user.email, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    else
      mail(subject: file_name, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    end
  end
end
