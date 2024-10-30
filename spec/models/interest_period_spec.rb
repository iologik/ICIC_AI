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
require 'rails_helper'

RSpec.describe InterestPeriod do
  it { is_expected.to validate_presence_of(:effect_date) }

  it { is_expected.to validate_presence_of(:per_annum) }

  it { is_expected.to validate_presence_of(:accrued_per_annum) }

  it { is_expected.to validate_numericality_of(:per_annum) }

  it { is_expected.to validate_numericality_of(:accrued_per_annum) }
end
