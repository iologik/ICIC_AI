# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: 'updates@innovationcic.com'

  def contact_mail(user_email, user_name, user_message)
    contact_email = ENV.fetch('contact_email')
    mail(to: contact_email, subject: "Messages from #{user_name}(#{user_email})", body: user_message)
  end

  def payments_pdf_email(receiver, pdf_handler, _all_payments, is_storage_object)
    attachments['payments.pdf'] = pdf_handler unless is_storage_object

    subject = "Generated Payment Report #{Time.zone.now.strftime('%Y-%m-%d')}"
    @is_storage_object = is_storage_object
    @pdf_handler = pdf_handler

    cc  = ENV['EMAIL_CC'].split(';')
    bcc = ENV['EMAIL_BCC'].split(';')
    mail(to: receiver, subject: subject, cc: cc, bcc: bcc)
  end
end
