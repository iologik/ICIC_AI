# frozen_string_literal: true

class AnnualPaymentRefer < AbstractPayment
  include AnnualTerm

  def initialize(sub_investment)
    super(sub_investment)
    @interest_rate = sub_investment.referrand_percent.to_f / 100.0 / 365.to_f # we do not care about Leap year, so use 365 for days of a year
  end

  private

  def payment_message(_end_date, _days)
    'Annually referrand payment'
  end

  def compute_interest_amount(start_date, end_date, amount, days = nil)
    [(days || (end_date - start_date)) * @interest_rate * amount, @interest_rate]
  end

  def pay_withdraw_payback
    false
  end

  def set_pay_user_id(sub_investment)
    @pay_user_id = sub_investment.referrand_user_id
  end
end
