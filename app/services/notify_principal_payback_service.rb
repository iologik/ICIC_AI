# frozen_string_literal: true

class NotifyPrincipalPaybackService < BaseService
  def call(principal_payment)
    pdf      = BuildPrincipalPaybackStatementService.new.call(principal_payment)
    filename = "#{principal_payment.sub_investment.admin_user.name}'s principal payback #{principal_payment.check_no}".tr(
      '/', '-'
    )
    pdf.render_file "#{filename}.pdf"
    PrincipalMailer.payback(principal_payment, filename, principal_payment.sub_investment.target_emails).deliver
    File.delete("#{filename}.pdf")
  end
end
