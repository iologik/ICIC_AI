# frozen_string_literal: true

# if pay_date is before last_paid_date, do not generate payment

class AbstractPaymentLoan
  attr_reader :id, :name, :start_date, :months, :ori_amount, :withdraws, :end_date, :pay_user_id, :interest_periods,
              :last_paid_date, :currency

  # rubocop:disable Metrics/AbcSize
  def initialize(loan)
    @id               = loan.id
    @name             = loan.name
    @start_date       = loan.start_date
    @months           = loan.months
    @ori_amount       = loan.ori_amount
    @withdraws        = loan.loan_draws
    @interest_periods = loan.loan_interest_periods.reorder('effect_date desc')
    @end_date         = start_date + months.to_i.months
    @last_paid_date   = loan.last_paid_date
    @currency         = loan.currency
    @pay_user_id      = loan.borrower.id

    set_pay_user_id loan
  end

  def set_termly_payments
    first_term = calculate_first_term(start_date)
    date = start_date
    next_term = first_term
    current_amount = ori_amount

    while date <= (temp_end_date = [end_date, next_term].min)
      # break if current_amount == 0

      temp_withdraws = withdraw_between(date, temp_end_date)
      if temp_withdraws.length.positive?
        payment_with_withdraws temp_withdraws, date, temp_end_date, current_amount
        # calculate new amount
        temp_withdraws.each do |withdraw|
          current_amount -= withdraw.real_amount
        end
      else
        payment_without_withdraw date, temp_end_date, current_amount
      end

      date = next_term
      next_term = calculate_next_payment_day(next_term)
    end

    # the last day
    return unless pay_withdraw_payback

    # check if there is withdraw
    withdraws.select { |w| w.due_date == end_date }.each do |withdraw|
      pay_withdraw(withdraw)
      current_amount -= withdraw.real_amount
    end
    # payback
    pay(end_date, current_amount, 'Payback Principal')
  end

  private

  # these methods do not need to be overridden
  # ================================================================

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def payment_with_withdraws(withdraws, date, temp_end_date, amount)
    # pay withdraws
    withdraws.each { |withdraw| pay_withdraw(withdraw) } if pay_withdraw_payback
    # calculate interests
    current_amount = amount
    current_date = date
    interest_before = 0
    withdraws.sort_by!(&:due_date).each do |withdraw|
      # compute interest_before
      if withdraw.due_date != current_date
        days = if term_days?([withdraw.due_date, current_date])
                 days_count_of_a_term
               else
                 (withdraw.due_date - current_date).to_i
               end
        interest_before += compute_interest_amount(current_date, withdraw.due_date, current_amount, days)[0]
        current_date = withdraw.due_date
      end
      # increase amount
      current_amount -= withdraw.real_amount
    end
    # if current_amount becomes to zero, the end_date should be the withdraw date
    pay_end_date = if current_amount.zero?
                     current_date
                   else
                     temp_end_date
                   end
    # interest_after
    interest_after_days = if term_days?([current_date, pay_end_date])
                            days_count_of_a_term
                          else
                            (pay_end_date - current_date).to_i
                          end
    interest_after, rate = compute_interest_amount(current_date, pay_end_date, current_amount, interest_after_days)
    # display days
    interest_days = if term_days?([pay_end_date, date])
                      days_count_of_a_term_for_display
                    else
                      (pay_end_date - date).to_i
                    end
    # pay interest
    pay(pay_end_date, interest_before + interest_after, payment_message(pay_end_date, interest_days), date,
        current_amount, rate)
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def payment_without_withdraw(date, temp_end_date, amount)
    if term_days?([temp_end_date, date])
      payment_amount, rate = compute_interest_amount(date, temp_end_date, amount, days_count_of_a_term)
      pay(temp_end_date, payment_amount, payment_message(temp_end_date, days_count_of_a_term_for_display), date,
          amount, rate)
    else
      days = (temp_end_date - date).to_i
      payment_amount, rate = compute_interest_amount(date, temp_end_date, amount, days)
      pay(temp_end_date, payment_amount, payment_message(temp_end_date, days), date, amount, rate)
    end
  end

  def withdraw_between(start_date, end_date)
    results = []
    withdraws.each do |with_draw|
      date = with_draw.due_date
      # NOTE: date >= start_date and date < end_date, it is important fo the withdraws(increases) on the start_date
      results << with_draw if ((date >= start_date) && (date < end_date)) && with_draw.amount
    end
    results
  end

  # payments on the 01.01.year should always be paid on 31.12.year-before
  # because tex reason
  def calculate_payment_date(date)
    if (date.month == 1) && (date.day == 1)
      date - 1
    else
      date
    end
  end

  def term_days?(date_array)
    date_array.each do |date|
      return false unless term_day?(date)
    end
    true
  end

  # pay withdraw
  # rubocop:disable Metrics/AbcSize
  def pay_withdraw(withdraw)
    return if !withdraw.should_generate_payment? || withdraw.amount.zero?

    kind = LoanPayment::TYPE_CASH_CALL
    paid = false
    pay_date = calculate_payment_date(withdraw.due_date)

    payment_data = { due_date: pay_date, amount: withdraw.amount, borrower_id: pay_user_id,
                     memo: "Cash Back #{withdraw.amount} from #{name}".capitalize,
                     payment_kind: kind, paid: paid, currency: currency }
    payment = LoanPayment.where(loan_id: id, cash_back_id: withdraw.id).first_or_create # we have to use withdraw_id, not depend on date, as there maybe two withdraws in one day
    payment.update(payment_data) unless payment.paid
  end
  # rubocop:enable Metrics/AbcSize

  # optional
  # ================================================================
  # todo I forget why I need start_date
  # rubocop:disable Metrics/ParameterLists
  def pay(date, amount, memo, start_date = nil, loan_amount = nil, rate = nil)
    return if amount.zero?

    # TODO: use another way to handle payment type
    kind = LoanPayment::TYPE_INTEREST
    kind = LoanPayment::TYPE_PRINCIPAL if memo.include? 'Principal'
    common_pay date, amount, kind, memo, start_date, nil, loan_amount, rate
  end

  def pay_with_kind(date, amount, kind, memo, start_date = nil, remark = nil)
    return if amount.zero?

    common_pay date, amount, kind, memo, start_date, remark
  end

  def common_pay(date, amount, kind, memo, start_date = nil, remark = nil, loan_amount = nil, rate = nil)
    pay_date = calculate_payment_date(date)
    # if pay_date is before last_paid_date, do not generate payment
    return if last_paid_date && (pay_date < last_paid_date)

    payment_data = { loan_id: id, due_date: pay_date, amount: amount, borrower_id: pay_user_id,
                     memo: memo.capitalize, payment_kind: kind, start_date: start_date, paid: false, remark: remark,
                     loan_amount: loan_amount, rate: (rate.nil? ? nil : rate * 365 * 100),
                     currency: currency }
    payment = LoanPayment.where(due_date: pay_date, loan_id: id, payment_kind: kind).first_or_create
    payment.update(payment_data) unless payment.paid
    payment
  end
  # rubocop:enable Metrics/ParameterLists

  # this method is very important
  # rubocop:disable Metrics/AbcSize
  def compute_interest_amount(start_date, end_date, amount, days = nil)
    dates = interest_periods.map(&:effect_date).delete_if { |d| d <= start_date || d >= end_date }
    dates << start_date
    dates << end_date
    dates.sort!
    if dates.length == 2
      rate = rate_for_date(start_date)
      result = (days || (end_date - start_date)) * rate * amount
    else
      result = 0
      (dates.length - 1).times do |i|
        rate = rate_for_date(dates[i])
        result += (dates[i + 1] - dates[i]) * rate * amount
      end
      result
    end
    [result, rate]
  end
  # rubocop:enable Metrics/AbcSize

  def rate_for_date(start_date)
    interest_periods.each do |ip|
      return ip.per_annum.to_f / 100.0 / 365.to_f if ip.effect_date <= start_date
    end
  end

  def pay_withdraw_payback
    true
  end

  def set_pay_user_id(loan)
    @pay_user_id = loan.borrower.id
  end

  # these methods need to be overridden
  # ================================================================

  def calculate_first_term(start_date); end

  def term_day?(date); end

  def days_count_of_a_term; end

  def days_count_of_a_term_for_display; end

  def payment_message(end_date, days); end

  def calculate_next_payment_day(date); end
end
