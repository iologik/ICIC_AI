# frozen_string_literal: true

class SendWithdrawEmailService
  include TargetEmail

  # This method is same to notify_investor method at Withdraw model, Need to remove those method in model
  def call(withdraw)
    pdf_obj  = BuildWithdrawService.new.call(withdraw)
    filename = "#{withdraw.admin_user.name}'s withdraw #{withdraw.check_no}".tr('/', '-')

    pdf_obj.render_file "#{filename}.pdf"

    WithdrawMailer.withdraw(withdraw, filename, target_email).deliver

    File.delete("#{filename}.pdf")
  end
end
