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
class LoanDraw < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :loan

  after_initialize :build_due_date
  after_create :increase_loan_amount # opposite as withdraw
  after_destroy :decrease_loan_amount

  def name
    "Draw of #{number_to_currency(amount, precision: 2)} from #{loan.display_name}"
  end

  def real_amount
    0 - amount
  end

  def should_generate_payment?
    false
  end

  private

  def build_due_date
    self.due_date = Time.zone.today unless due_date
  end

  def increase_loan_amount
    loan.affect_investment(0 - amount) # NOTE: it is 0-amount here
    loan.adjust_payment # payments should be regenerated after creating an increase
  end

  def decrease_loan_amount
    loan.affect_investment(amount) # NOTE: it is amount here
    loan.adjust_payment # payments should be regenerated after destroying an increase
  end
end
