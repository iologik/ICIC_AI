# frozen_string_literal: true

# == Schema Information
#
# Table name: loan_interest_periods
#
#  id          :integer          not null, primary key
#  effect_date :date
#  per_annum   :decimal(, )
#  loan_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class LoanInterestPeriod < ApplicationRecord
  # attr_accessible :effect_date, :per_annum

  belongs_to :borrower, optional: true

  validates :effect_date, presence: true
  validates :per_annum, numericality: { greater_than_or_equal_to: 0 }, presence: true
end
