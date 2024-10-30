# frozen_string_literal: true

class UpdateWithdrawFromPaymentService
  def call(payment)
    withdraw = payment.withdraw

    pay_date = calculate_payment_date(withdraw.due_date)
    withdraw_param = {
      due_date: pay_date,
      amount: payment.amount,
      paid: payment.paid,
      paid_date: payment.paid_date,
      check_no: payment.check_no,
    }

    withdraw.update!(withdraw_param)
  end

  def calculate_payment_date(date)
    if (date.month == 1) && (date.day == 1)
      date - 1
    else
      date
    end
  end
end
