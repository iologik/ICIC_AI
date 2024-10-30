# frozen_string_literal: true

class PaymentsMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  # rubocop:disable Metrics/AbcSize
  def payments_email(admin_user, check_no, payments, file_name)
    @check_no     = check_no
    @payments     = payments
    @total_amount = payments.sum(&:amount)
    payment       = payments.first
    @date         = payment.paid_date.strftime('%Y-%m-%d')
    @currency     = payment.sub_investment.currency
    attachments["#{file_name}.pdf"] = File.read("#{file_name}.pdf")

    admin_user.email
    cc  = ENV['EMAIL_CC'].split(';')
    bcc = ENV['EMAIL_BCC'].split(';')
    if Rails.env.production?
      mail(subject: file_name, to: admin_user.email, cc: cc, bcc: bcc)
    else
      mail(subject: file_name, cc: cc, bcc: bcc)
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/ParameterLists
  def transfer(admin_user, old_sub_investment, new_sub_investment, transfer_amount, transfer_currency, payment_type)
    @admin_user = admin_user
    @old_sub_investment = old_sub_investment
    @new_sub_investment = new_sub_investment
    @transfer_amount = transfer_amount
    @transfer_currency = transfer_currency
    @payment_type = payment_type

    subject = 'Payment Transfer'
    to  = admin_user.email
    cc  = ENV['EMAIL_CC'].split(';')
    bcc = ENV['EMAIL_BCC'].split(';')
    if Rails.env.production?
      mail(subject: subject, to: to, cc: cc, bcc: bcc)
    else
      mail(subject: subject, cc: cc, bcc: bcc)
    end
  end
  # rubocop:enable Metrics/ParameterLists
end
