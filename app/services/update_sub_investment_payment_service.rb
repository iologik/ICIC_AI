# frozen_string_literal: true

class UpdateSubInvestmentPaymentService < BaseService
  attr_accessor :sub_investment

  def initialize(sub_investment_id)
    @sub_investment = SubInvestment.find(sub_investment_id)
  end

  def call
    return if sub_investment.per_annum.nil? || sub_investment.accrued_per_annum.nil? || sub_investment.amount.nil?

    # delete unpaid payments (previous logic, comment out according to the new requirements from Nick)
    delete_unpaid_payments
    # accrued only payments, this scenario does not offen appear
    set_payments
  end

  def delete_unpaid_payments
    sub_investment.payments.each do |o|
      next if (o.amf_payment? && sub_investment.amount.zero?) || o.paid

      o.destroy
    end
  end

  def set_payments
    accrued_per_annum  = sub_investment.accrued_per_annum
    retained_per_annum = sub_investment.retained_per_annum
    per_annum          = sub_investment.per_annum
    if per_annum.zero? && (accrued_per_annum.positive? || retained_per_annum.positive?)
      annum_zero_set_payments(accrued_per_annum, retained_per_annum)
    else
      annum_non_zero_set_payments
    end
  end

  def annum_zero_set_payments(accrued_per_annum, retained_per_annum)
    AccruedPayment.new(sub_investment, payback_and_withdraw: true).set_payments if accrued_per_annum.positive?
    RetainedPayment.new(sub_investment, payback_and_withdraw: true).set_payments if retained_per_annum.positive?

    pay_referrand
  end

  def annum_non_zero_set_payments
    # monthly/quarterly payments
    payment_set_termly_payments
    # ...
    AccruedPayment.new(sub_investment).set_payments
    RetainedPayment.new(sub_investment).set_payments
    pay_referrand

    update_related_records
  end

  def payment_set_termly_payments
    if sub_investment.monthly?
      MonthPayment.new(sub_investment).set_termly_payments
    elsif sub_investment.quarterly?
      QuarterPayment.new(sub_investment).set_termly_payments
    else
      AnnualPayment.new(sub_investment).set_termly_payments
    end
  end

  def pay_referrand
    return if referrand_unavailable

    # percent referrand
    payment_refer_set_termly_payments if sub_investment.referrand_percent.present?

    # fixed price referrand
    return if sub_investment.referrand_one_time_amount.blank?

    referrand_one_time_date   = sub_investment.referrand_one_time_date
    referrand_one_time_amount = sub_investment.referrand_one_time_amount
    referrand_user_id         = sub_investment.referrand_user_id
    sub_investment.pay(referrand_one_time_date, referrand_one_time_amount, 'referrand payment', referrand_user_id)
  end

  def referrand_unavailable
    (sub_investment.referrand_percent.nil? && sub_investment.referrand_one_time_amount.nil?) ||
      sub_investment.referrand_user_id.nil?
  end

  def payment_refer_set_termly_payments
    if sub_investment.referrand_scheduled.include? 'Month'
      MonthPaymentRefer.new(sub_investment).set_termly_payments
    elsif sub_investment.referrand_scheduled.include? 'Quarter'
      QuarterPaymentRefer.new(sub_investment).set_termly_payments
    else
      AnnualPaymentRefer.new(sub_investment).set_termly_payments
    end
  end

  def update_related_records
    UpdateSubInvestmentAmountStatsService.new(sub_investment.id).call
    UpdateSubInvestorAmountService.new(sub_investment.admin_user_id).call
    UpdateInvestmentAmountService.new(sub_investment.investment_id).call
    UpdateInvestmentStatsWorker.perform_async(sub_investment.investment_id)
  end
end
