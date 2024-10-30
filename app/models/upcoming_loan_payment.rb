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
class UpcomingLoanPayment < LoanPayment
  # prev/this/next month
  def self.due_next_month_cad
    LoanPayment.where(due_date: (Time.zone.today.at_beginning_of_month - 1.month)..(Time.zone.today.at_end_of_month + 1.month), currency: 'CAD', paid: false).reorder(:due_date)
  end

  # prev/this/next month
  def self.due_next_month_usd
    LoanPayment.where(due_date: (Time.zone.today.at_beginning_of_month - 1.month)..(Time.zone.today.at_end_of_month + 1.month), currency: 'USD', paid: false).reorder(:due_date)
  end
end
