# frozen_string_literal: true

# == Schema Information
#
# Table name: loan_draws
#
#  id         :integer          not null, primary key
#  loan_id    :integer
#  amount     :float
#  due_date   :date
#  check_no   :string(255)
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CashBack < LoanDraw
  after_create :adjust_payments
  after_destroy :adjust_payments
  # after_commit :adjust_payments # todo why have to use after_commit here ?

  has_one :loan_payment, dependent: :destroy # not include loan_draw

  def name
    "Cash Back #{number_to_currency(amount, precision: 2)} for #{loan.display_name}"
  end

  def real_amount
    amount
  end

  def adjust_payments
    return unless amount && loan

    loan.adjust_payment
  end

  def should_generate_payment?
    true
  end

  # override loan_draw
  def increase_loan_amount; end

  # override loan_draw
  def decrease_loan_amount; end
end
