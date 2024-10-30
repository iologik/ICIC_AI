# frozen_string_literal: true

module MonthTerm
  def calculate_first_term(start_date)
    start_date.beginning_of_month.next_month
  end

  def term_day?(date)
    date.day == 1
  end

  def days_count_of_a_term
    30.4166
  end

  def days_count_of_a_term_for_display
    30.4
  end

  def calculate_next_payment_day(date)
    date.next_month
  end
end
