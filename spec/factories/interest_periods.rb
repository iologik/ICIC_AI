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
FactoryBot.define do
  factory :interest_period do
    effect_date { Date.parse('2012-01-05') }
    per_annum { 12 }
    accrued_per_annum { 2 }

    # sub_investment
  end
end
