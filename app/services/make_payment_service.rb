# frozen_string_literal: true

class MakePaymentService
  attr_accessor :payment, :sub_investment, :sub_investment_id, :withdraw, :paid, :payment_kind

  def initialize(payment)
    @payment           = payment
    @paid              = payment.paid
    @payment_kind      = payment.payment_kind
    @sub_investment    = payment.sub_investment
    @withdraw          = payment.withdraw
    @sub_investment_id = payment.sub_investment_id
  end

  def withdraw_transfer_principal_types
    [Payment::Type_Withdraw, Payment::Type_Transfer, Payment::Type_Principal]
  end

  def call(check_no = nil, due_date = nil, paid_date = nil)
    update_sub_investment

    update_withdraw

    update_payment check_no, due_date, paid_date

    UpdateSubInvestmentPaymentWorker.perform_async(sub_investment_id)
  end

  def update_sub_investment
    sub_investment.affect_investment(amount) if payment_kind.in?(withdraw_transfer_principal_types) && !paid
  end

  def update_withdraw
    withdraw.update(paid: paid) if withdraw && paid != withdraw.paid
  end

  def update_payment(check_no, due_date, paid_date)
    payment.check_no = check_no if check_no
    payment.paid = true
    payment.due_date = due_date if payment_kind.in?(withdraw_transfer_principal_types) && due_date.present?
    payment.paid_date = paid_date if paid_date
    payment.save!
  end
end
