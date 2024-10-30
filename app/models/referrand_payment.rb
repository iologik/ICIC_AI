# frozen_string_literal: true

module ReferrandPayment
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def pay_referrand
    return if referrand_user_id.nil?
    return if referrand_percent.nil? && referrand_one_time_amount.nil?

    # percent referrand
    if referrand_percent.present?
      if referrand_scheduled.include? 'Month'
        MonthPaymentRefer.new(self).set_termly_payments
      elsif referrand_scheduled.include? 'Quarter'
        QuarterPaymentRefer.new(self).set_termly_payments
      else
        AnnualPaymentRefer.new(self).set_termly_payments
      end
    end

    # fixed price referrand
    return if referrand_one_time_amount.blank?

    pay(referrand_one_time_date, referrand_one_time_amount, 'referrand payment', referrand_user_id)
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
end
