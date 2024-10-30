# frozen_string_literal: true

module ModelMacros
  # params: per_annum, accrued_per_annum
  def create_sub_investment(interest_options, sub_investment_options = {})
    sub_investment = FactoryBot.build(:sub_investment, sub_investment_options)
    sub_investment.interest_periods = [FactoryBot.build(:interest_period, { sub_investment: sub_investment }.merge(interest_options))]
    sub_investment.save(validation: false)
    sub_investment
  end

  def general_sub_investment
    create_sub_investment({ per_annum: 12, accrued_per_annum: 2 }, creation_date: Time.zone.today)
  end

  def customize_sub_investment(options)
    create_sub_investment({ per_annum: 12, accrued_per_annum: 2 }, options)
  end

  # payments on the 01.01.year should always be paid on 31.12.year-before
  # because tex reason
  def calculate_payment_date(date)
    (date.month == 1) && (date.day == 1) ? (date - 1) : date
  end
end
