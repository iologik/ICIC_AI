# frozen_string_literal: true

class AgreementMailer < ApplicationMailer
  default from: 'updates@innovationcic.com', to: proc { ENV['admin_emails'].split(',') }

  def agreement_email(sub_investment)
    @sub_investment = sub_investment
    emails = ENV['admin_emails'].split(',') + [sub_investment.admin_user.email]
    subject = "Agreement for #{@sub_investment.name}"
    cc      = ENV['EMAIL_CC'].split(';')
    bcc     = ENV['EMAIL_BCC'].split(';')
    mail(to: emails, subject: subject, cc: cc, bcc: bcc)
  end
end
