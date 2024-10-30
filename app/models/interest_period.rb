# frozen_string_literal: true

# == Schema Information
#
# Table name: interest_periods
#
#  id                 :integer          not null, primary key
#  effect_date        :date
#  per_annum          :decimal(, )
#  accrued_per_annum  :decimal(, )
#  sub_investment_id  :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  retained_per_annum :decimal(, )
#
class InterestPeriod < ApplicationRecord
  # attr_accessible :effect_date, :per_annum, :accrued_per_annum

  belongs_to :sub_investment, optional: true

  validates :effect_date, presence: true
  validates :per_annum, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :accrued_per_annum, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :retained_per_annum, numericality: { greater_than_or_equal_to: 0 }, presence: true

  after_initialize :set_default_per_annum

  private

  def set_default_per_annum
    self.per_annum ||= 0.0
    self.accrued_per_annum ||= 0.0
    self.retained_per_annum ||= 0.0
  end
end
