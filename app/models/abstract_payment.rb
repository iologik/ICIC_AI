# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/ParameterLists
class AbstractPayment
  attr_reader :id, :name, :start_date, :months, :ori_amount, :withdraws, :end_date, :pay_user_id, :interest_periods,
              :last_paid_date, :last_paid_type, :currency, :sub_investment

  def initialize(sub_investment)
    @id               = sub_investment.id
    @name             = sub_investment.name
    @start_date       = sub_investment.start_date
    @months           = sub_investment.months
    @ori_amount       = sub_investment.ori_amount
    @withdraws        = sub_investment.withdraws
    @interest_periods = sub_investment.interest_periods.reorder('effect_date desc')
    @end_date         = start_date + months.to_i.months
    @last_paid_date   = sub_investment.last_paid_payment_due_date
    @last_paid_type   = sub_investment.last_paid_type
    @currency         = sub_investment.currency
    @sub_investment   = sub_investment
    @pay_user_id      = sub_investment.admin_user_id

    @end_date = [@end_date, sub_investment.principal_paid_date, sub_investment.principal_due_date].min if sub_investment.principal_paid_date

    set_pay_user_id(sub_investment)
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
    return unless pay_withdraw_payback && !sub_investment.principal_paid?

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
    # puts "#{start_date},#{end_date}"
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
    (date.month == 1) && (date.day == 1) ? date - 1 : date
  end

  def term_days?(date_array)
    date_array.each do |date|
      return false unless term_day?(date)
    end
    true
  end

  # pay withdraw
  def pay_withdraw(withdraw)
    return if !withdraw.should_generate_payment? || withdraw.amount.zero?

    if withdraw.is_transfer
      kind = Payment::Type_Transfer
      paid = true
    else
      kind = Payment::Type_Withdraw
      paid = withdraw.paid
    end
    pay_date = calculate_payment_date(withdraw.due_date)

    payment_data = {
      due_date: pay_date,
      amount: withdraw.amount,
      admin_user_id: pay_user_id,
      memo: withdraw.payment_message(name).capitalize,
      payment_kind: kind,
      paid: paid,
      currency: currency,
      sub_investment_id: id,
      withdraw_id: withdraw.id,
      paid_date: withdraw.paid_date,
      check_no: withdraw.check_no,
    }
    payment = Payment.find_by(sub_investment_id: id, withdraw_id: withdraw.id) # we have to use withdraw_id, not depend on date, as there maybe two withdraws in one day
    if payment
      payment.update(payment_data) unless payment.paid
    else
      Payment.create(payment_data)
    end
  end

  # optional
  # ================================================================
  # todo I forget why I need start_date
  def pay(date, amount, memo, start_date = nil, sub_investment_amount = nil, rate = nil)
    return if amount.zero?

    # TODO: use another way to handle payment type
    kind = Payment::Type_Interest
    kind = Payment::Type_AMF if memo.include? 'refer'
    kind = Payment::Type_Principal if memo.include? 'Principal'
    kind = Payment::Type_Accrued if memo.include? 'Accrued'
    common_pay date, amount, kind, memo, start_date, nil, sub_investment_amount, rate
  end

  def pay_with_kind(date, amount, kind, memo, start_date = nil, remark = nil)
    return if amount.zero?

    common_pay date, amount, kind, memo, start_date, remark
  end

  def common_pay(date, amount, kind, memo, start_date = nil, remark = nil, sub_investment_amount = nil, rate = nil)
    pay_date = calculate_payment_date(date)
    if last_paid_date && (pay_date < last_paid_date) && (kind == last_paid_type) && !kind.in?([Payment::Type_Accrued,
                                                                                               Payment::Type_Retained])
      return
    end
    return if last_paid_date && (pay_date == last_paid_date) && (kind == last_paid_type) && (kind == Payment::Type_Interest)

    payment_data = { sub_investment_id: id, due_date: pay_date, amount: amount, admin_user_id: pay_user_id,
                     memo: memo.capitalize, payment_kind: kind, start_date: start_date, paid: false, remark: remark,
                     sub_investment_amount: sub_investment_amount, rate: (rate.nil? ? nil : rate * 365 * 100),
                     currency: currency }

    payment_checker = Payment.where(due_date: pay_date, sub_investment_id: id, payment_kind: kind)
    if payment_checker.exists?
      payment_checker.first
    else
      payment = Payment.where(due_date: pay_date, sub_investment_id: id, payment_kind: kind,
                              amount: amount.to_f.round(2)).first_or_create
      payment.update(payment_data) unless payment.paid
      payment
    end
  end

  # this method is very important
  def compute_interest_amount(start_date, end_date, amount, days = nil)
    dates = interest_periods.map(&:effect_date).delete_if { |d| d <= start_date || d >= end_date }
    dates << start_date
    dates << end_date
    dates.sort!
    if dates.length == 2
      rate = rate_for_date(start_date)
      result = (days || (end_date - start_date)) * rate * amount.to_f
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

  def rate_for_date(start_date)
    interest_periods.each do |ip|
      return ip.per_annum.to_f / 100.0 / 365.to_f if ip.effect_date <= start_date
    end
  end

  def pay_withdraw_payback
    true
  end

  def set_pay_user_id(sub_investment)
    @pay_user_id = sub_investment.admin_user_id
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
# rubocop:enable Metrics/ParameterLists
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/AbcSize
