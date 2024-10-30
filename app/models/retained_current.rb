# frozen_string_literal: true

class RetainedCurrent
  attr_reader :id, :name, :start_date, :months, :ori_amount, :withdraws, :end_date, :pay_user_id, :interest_periods,
              :final_amount, :final_steps, :sub_investment, :paid

  def initialize(sub_investment, start_date = nil, end_date = nil, paid: false)
    @sub_investment   = sub_investment
    @id               = sub_investment.id
    @start_date       = start_date && start_date > sub_investment.start_date ? start_date : sub_investment.start_date
    @ori_amount       = sub_investment.ori_amount
    @withdraws        = sub_investment.withdraws
    @interest_periods = sub_investment.interest_periods.sort { |x, y| y.effect_date <=> x.effect_date }

    @end_date         = end_date || Time.zone.today
    @paid             = paid
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  def compute_amount
    if paid
      @final_amount = paid_retained
    else
      # pay retained
      withdraws_retained = 0
      steps = []
      current_amount = ori_amount
      current_date = start_date
      withdraw_hash = withdraws.to_a.group_by(&:due_date)
      withdraw_hash.keys.sort.each do |date|
        break if date > end_date

        withdraws_by_date = withdraw_hash[date]
        new_current_amount = current_amount
        withdraws_by_date.each do |withdraw|
          if withdraw.type == 'Increase'
            new_current_amount += withdraw.amount
          else
            new_current_amount -= withdraw.amount
          end
        end
        # steps and amount for retained
        amount, temp_steps = compute_retained_amount(current_date, date, current_amount)
        withdraws_retained += amount
        steps << temp_steps
        # change current amount and date
        current_amount = new_current_amount
        current_date = date
      end

      real_end_date = [end_date, sub_investment.end_date].min

      # pay retained
      amount, temp_steps = compute_retained_amount(current_date, real_end_date, current_amount)
      withdraws_retained += amount
      steps << temp_steps

      @final_steps = steps.join("+\n")
      @final_amount = withdraws_retained - paid_retained
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize

  # increase amount
  def retained_for_transfer
    retained_amount = 0
    steps = ''
    withdraws.select { |x| x.type == 'Increase' }.sort_by(&:due_date).each do |withdraw|
      amount, temp_steps = compute_retained_amount(withdraw.due_date, end_date, withdraw.amount)
      retained_amount += amount
      steps += temp_steps
    end
    [retained_amount, steps]
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def compute_retained_amount(start_date, end_date, amount)
    dates = interest_periods.map(&:effect_date).delete_if { |d| d <= start_date || d >= end_date }
    dates << start_date
    dates << end_date
    dates.sort!
    if dates.length == 2
      day_rate, rate = rate_for_date(start_date)
      result = begin
        (end_date - start_date) * day_rate * amount
      rescue
        0
      end
      steps = calculate_string(start_date, end_date, rate, amount)
    else
      result = 0
      steps = ''
      (dates.length - 1).times do |i|
        day_rate, rate = rate_for_date(dates[i])
        result += begin
          (dates[i + 1] - dates[i]) * day_rate * amount
        rescue
          0
        end
        steps += calculate_string(dates[i], dates[i + 1], rate, amount)
        steps += "+\n" if i != (dates.length - 2)
      end
    end
    [result, steps]
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def calculate_string(start_date, end_date, rate, amount)
    "#{sub_investment.name} - #{(end_date - start_date).to_i} days from #{start_date.strftime('%Y-%m-%d')} to #{end_date.strftime('%Y-%m-%d')} with rate #{rate}% for #{format_currency(amount)}\n"
    # puts "====#{step}"
  end

  def format_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount, precision: 2)
  end

  def rate_for_date(start_date)
    interest_periods.each do |ip|
      return [ip.retained_per_annum.to_f / 100.0 / 365.to_f, ip.retained_per_annum] if ip.effect_date <= start_date
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def paid_retained
    retained_paid_payments = sub_investment.payments.select do |x|
      (x.payment_kind == Payment::Type_Retained) && x.paid && x.paid_date >= start_date && x.paid_date <= end_date
    end
    @paid_retained ||= (retained_paid_payments.sum(&:amount) || 0)
  end

  def pending_retained
    retained_pending_payments = sub_investment.payments.select do |x|
      (x.payment_kind == Payment::Type_Retained) && x.paid == false && x.due_date >= start_date && x.due_date <= end_date
    end
    @pending_retained ||= (retained_pending_payments.sum(&:amount) || 0)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
