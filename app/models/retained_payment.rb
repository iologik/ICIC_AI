# frozen_string_literal: true

class RetainedPayment < AbstractPayment
  attr_reader :paid_retained_payments

  def initialize(sub_investment, payback_and_withdraw: false)
    super sub_investment
    @payback_and_withdraw = payback_and_withdraw
    @paid_retained_payments = sub_investment.payments.where(payment_kind: 'Retained', paid: true)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def set_termly_payments
    # pay retained
    withdraws_retained = 0
    steps = []
    current_amount = ori_amount
    current_date = start_date
    pay_date = start_date

    # consider retained payment to generate pending retained payment
    paid_retained_payments.each do |paid_retained_payment|
      # pay date and current_date could be different
      pay_date = paid_retained_payment.due_date if pay_date < paid_retained_payment.due_date

      current_date = paid_retained_payment.due_date if current_date < paid_retained_payment.due_date
    end

    withdraw_hash = withdraws.to_a.group_by(&:due_date)
    withdraw_hash.keys.sort.each do |date|
      next if date < current_date

      there_is_withdraw = false
      withdraws_by_date = withdraw_hash[date]
      new_current_amount = current_amount
      withdraws_by_date.each do |withdraw|
        if withdraw.type == 'Increase'
          new_current_amount += withdraw.amount
        else
          new_current_amount -= withdraw.amount
          there_is_withdraw = true
        end
      end
      # steps and amount for retained
      amount, temp_steps = compute_retained_amount(current_date, date, current_amount)
      withdraws_retained += amount
      steps << temp_steps
      # pay retained
      if there_is_withdraw
        # pay retained
        pay_retained(pay_date, date, withdraws_retained, steps.join("+\n"))
        pay_date = date
        # clear retained
        withdraws_retained = 0
        steps = []
      end
      # change current amount and date
      current_amount = new_current_amount
      current_date = date
    end

    # pay retained
    amount, temp_steps = compute_retained_amount(current_date, end_date, current_amount)
    withdraws_retained += amount
    steps << temp_steps
    pay_retained(pay_date, end_date, withdraws_retained, steps.join("+\n"))

    # pay withdraws and principal
    withdraws.order('due_date').each do |withdraw|
      next if withdraw.type == 'Increase'

      pay_withdraw(withdraw) if pay_withdraw_payback
    end
    pay(end_date, current_amount, 'Payback Principal') if pay_withdraw_payback
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def pay_retained(start_date, end_date, final_amount, remark)
    pay_with_kind(end_date, final_amount, Payment::Type_Retained,
                  "#{(end_date - start_date).to_i} days from #{start_date.strftime('%Y-%m-%d')} to #{end_date.strftime('%Y-%m-%d')}", nil, remark)
  end

  alias set_payments set_termly_payments

  private

  def payment_message(end_date, days); end

  # rubocop:disable Metrics/AbcSize
  def compute_retained_amount(start_date, end_date, amount)
    dates = interest_periods.map(&:effect_date).delete_if { |d| d <= start_date || d >= end_date }
    dates << start_date
    dates << end_date
    dates.sort!
    if dates.length == 2
      day_rate, rate = rate_for_date(start_date)
      result = (end_date - start_date) * day_rate * amount.to_f
      steps = calculate_string(start_date, end_date, rate, amount)
    else
      result = 0
      steps = ''
      (dates.length - 1).times do |i|
        day_rate, rate = rate_for_date(dates[i])
        result += (dates[i + 1] - dates[i]) * day_rate * amount
        steps += calculate_string(dates[i], dates[i + 1], rate, amount)
        steps += "+\n" if i != (dates.length - 2)
      end
    end
    [result, steps]
  end
  # rubocop:enable Metrics/AbcSize

  def rate_for_date(start_date)
    interest_periods.each do |ip|
      return [ip.retained_per_annum.to_f / 100.0 / 365.to_f, ip.retained_per_annum] if ip.effect_date <= start_date
    end
  end

  def pay_withdraw_payback
    @payback_and_withdraw
  end

  def format_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount, precision: 2)
  end

  def calculate_string(start_date, end_date, rate, amount)
    "#{(end_date - start_date).to_i} days from #{start_date.strftime('%Y-%m-%d')} to #{end_date.strftime('%Y-%m-%d')} with rate #{rate}% for #{format_currency(amount)}\n"
  end
end
