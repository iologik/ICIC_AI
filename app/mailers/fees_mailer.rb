# frozen_string_literal: true

class FeesMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  def create(fee)
    @sub_investment = fee.sub_investment
    @admin_user = @sub_investment.admin_user
    @investment = @sub_investment.investment

    cc  = ENV['EMAIL_CC'].split(';')
    bcc = ENV['EMAIL_BCC'].split(';')
    if Rails.env.production?
      mail(to: @admin_user.email, cc: cc, bcc: bcc)
    else
      mail(cc: cc, bcc: bcc)
    end
  end
end
