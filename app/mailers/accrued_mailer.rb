# frozen_string_literal: true

class AccruedMailer < ApplicationMailer
  default from: 'updates@innovationcic.com', to: proc { ENV['admin_emails'].split(',') }

  # rubocop:disable Metrics/AbcSize
  def notify(sub_investment, date, file_name)
    @sub_investment = sub_investment
    @date = Date.parse date
    subject = "Current accrued for #{@sub_investment.investment.name}"
    to      = @sub_investment.admin_user.email
    cc      = ENV['EMAIL_CC'].split(';')
    bcc     = ENV['EMAIL_BCC'].split(';')
    attachments["#{file_name}.pdf"] = File.read("#{file_name}.pdf")

    if Rails.env.production?
      mail(subject: subject, to: to, cc: cc, bcc: bcc)
    else
      mail(subject: subject, cc: cc, bcc: bcc)
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def batch_notify(sub_investments, date, file_name)
    return if sub_investments.blank?

    @sub_investments = sub_investments
    @sub_investment = sub_investments.first
    @date = Date.parse date
    @sum_usd = 0
    @sum_cad = 0
    @sum_usd = @sub_investments.inject(0) do |sum, x|
      x.currency == 'USD' ? sum + x.current_accrued_subinvest_currency(@date) : sum
    end
    @sum_cad = @sub_investments.inject(0) do |sum, x|
      x.currency == 'CAD' ? sum + x.current_accrued_subinvest_currency(@date) : sum
    end

    subject = "Current accrued for #{sub_investments.map { |sub_investment| sub_investment.investment.name }.join(',')}"
    to      = @sub_investment.admin_user.email
    cc      = ENV['EMAIL_CC'].split(';')
    bcc     = ENV['EMAIL_BCC'].split(';')
    attachments["#{file_name}.pdf"] = File.read("#{file_name}.pdf")

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
