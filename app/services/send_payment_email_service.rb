# frozen_string_literal: true

class SendPaymentEmailService
  def call(payments, check_no = nil)
    pdf = BuildPaymentsPDFService.new.call(payments)
    admin_user = payments.first.admin_user
    check_no ||= payments.first.check_no
    filename = "#{admin_user.name}'s payments #{check_no}"
    filename = filename.tr('/', '-')

    pdf.render_file "#{filename}.pdf"
    PaymentsMailer.payments_email(admin_user, check_no, payments, filename).deliver
    File.delete("#{filename}.pdf")

    true
  end
end
