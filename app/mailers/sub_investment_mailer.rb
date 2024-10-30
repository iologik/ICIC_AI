# frozen_string_literal: true

class SubInvestmentMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  def sub_investment_mail(sub_investment, file_name, emails)
    @sub_investment = sub_investment
    attachments["#{file_name}.pdf"] = File.read("#{file_name}.pdf")
    if Rails.env.production?
      mail(subject: file_name, to: emails, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    else
      mail(subject: file_name, cc: ENV['EMAIL_CC'].split(';'), bcc: ENV['EMAIL_BCC'].split(';'))
    end
  end
end
