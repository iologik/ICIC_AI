# frozen_string_literal: true

class UpdatePaymentFromWithdrawService
  attr_accessor :payment_kind, :paid, :paid_date, :check_no, :due_date, :amount, :withdraw

  def call(withdraw)
    payment = withdraw.payment
    return if payment.nil?

    @withdraw = withdraw

    set_paid_and_kind
    set_other_params

    update_payment!
  end

  def set_paid_and_kind
    if withdraw.is_transfer
      @payment_kind = Payment::Type_Transfer
      @paid         = true
    else
      @payment_kind = Payment::Type_Withdraw
      @paid         = withdraw.paid
    end
  end

  def set_other_params
    @amount    = withdraw.amount
    @due_date  = calculate_payment_date(withdraw.due_date)
    @check_no  = withdraw.check_no
    @paid_date = withdraw.paid_date
  end

  def calculate_payment_date(date)
    if (date.month == 1) && (date.day == 1)
      date - 1
    else
      date
    end
  end

  def update_payment!
    withdraw.payment.update!(payment_param)
  end

  def payment_param
    {
      paid: paid,
      amount: amount,
      due_date: due_date,
      check_no: check_no,
      paid_date: paid_date,
      payment_kind: payment_kind,
    }
  end
end
