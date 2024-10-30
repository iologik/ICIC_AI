# frozen_string_literal: true

class IncreaseMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  def increase(increase, file_name, emails)
    @increase = increase
    attachments["#{file_name}.pdf"] = File.read("#{file_name}.pdf")
    cc  = ENV['EMAIL_CC'].split(';')
    bcc = ENV['EMAIL_BCC'].split(';')
    if Rails.env.production?
      mail(subject: file_name, to: emails, cc: cc, bcc: bcc)
    else
      mail(subject: file_name, cc: cc, bcc: bcc)
    end
  end
end
