# frozen_string_literal: true

# == Schema Information
#
# Table name: loan_payments
#
#  id           :integer          not null, primary key
#  loan_id      :integer
#  borrower_id  :integer
#  cash_back_id :integer
#  payment_kind :string(255)
#  due_date     :date
#  check_no     :string(255)
#  memo         :string(255)
#  paid         :boolean          default(FALSE)
#  amount       :decimal(12, 2)
#  start_date   :date
#  remark       :text
#  loan_amount  :decimal(12, 2)
#  currency     :string(255)
#  rate         :decimal(12, 2)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class LoanPayment < ApplicationRecord
  belongs_to :loan
  belongs_to :cash_back
  belongs_to :borrower

  TYPE_INTEREST = 'Interest'
  TYPE_AMF = 'AMF'
  TYPE_PRINCIPAL = 'Principal'
  TYPE_CASH_CALL = 'Cash Back'

  after_save :paid_callback

  def self.payment_for_cash_back(cash_back)
    return cash_back.loan_payment if cash_back.loan_payment

    kind = TYPE_CASH_CALL
    cash_back.loan.loan_payments.where(payment_kind: kind, due_date: cash_back.due_date).first
  end

  def display_name
    "#{loan.name} #{due_date}"
  end

  def status
    if paid
      'Paid'
    else
      'Pending'
    end
  end

  def paid!(check_no = 'PAID')
    self.check_no = check_no
    self.paid = true
    save
  end

  def pay_payment?
    paid && paid_was == false # paid_was maybe nil
  end

  # def pending!
  #  self.check_no = nil
  #  self.paid = false
  #  self.save
  # end

  private

  def unpaid_payment?
    (paid == false) and paid_was
  end

  def paid_callback
    return unless payment_kind == TYPE_CASH_CALL

    loan.affect_investment(amount) if pay_payment? # decrease
    loan.affect_investment(0 - amount) if unpaid_payment? # increase
  end
end
