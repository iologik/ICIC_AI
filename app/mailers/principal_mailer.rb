# frozen_string_literal: true

class PrincipalMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  def payback(payment, file_name, emails)
    @payment = payment
    attachments["#{file_name}.pdf"] = File.read("#{file_name}.pdf")
    if Rails.env.production?
      mail(subject: file_name, to: emails, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    else
      mail(subject: file_name, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    end
  end
end
