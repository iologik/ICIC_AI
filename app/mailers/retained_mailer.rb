# frozen_string_literal: true

class RetainedMailer < ApplicationMailer
  default from: 'updates@innovationcic.com', to: proc { ENV['admin_emails'].split(',') }

  def notify(sub_investment, date)
    @sub_investment = sub_investment
    @date = Date.parse date

    subject = "Current Interest Reserve for #{@sub_investment.investment.name}"
    to      = @sub_investment.admin_user.email
    cc      = ENV['EMAIL_CC'].split(';')
    bcc     = ENV['EMAIL_BCC'].split(';')
    if Rails.env.production?
      mail(subject: subject, to: to, cc: cc, bcc: bcc)
    else
      mail(subject: subject, cc: cc, bcc: bcc)
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def batch_notify(sub_investments, date)
    return if sub_investments.blank?

    @sub_investments = sub_investments
    @sub_investment = sub_investments.first
    @date = Date.parse date
    @sum_usd = 0
    @sum_cad = 0
    @sum_usd = @sub_investments.inject(0) do |sum, x|
      x.currency == 'USD' ? sum + x.current_retained_subinvest_currency(@date) : sum
    end
    @sum_cad = @sub_investments.inject(0) do |sum, x|
      x.currency == 'CAD' ? sum + x.current_retained_subinvest_currency(@date) : sum
    end

    subject = "Current Interest Reserve for #{sub_investments.map do |sub_investment|
                                                sub_investment.investment.name
                                              end.join(',')}"
    to      = @sub_investment.admin_user.email
    cc      = ENV['EMAIL_CC'].split(';')
    bcc     = ENV['EMAIL_BCC'].split(';')
    if Rails.env.production?
      mail(subject: subject, to: to, cc: cc, bcc: bcc)
    else
      mail(subject: subject, cc: cc, bcc: bcc)
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
end
