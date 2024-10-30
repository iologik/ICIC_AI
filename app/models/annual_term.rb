# frozen_string_literal: true

module AnnualTerm
  def calculate_first_term(start_date)
    Date.parse("31/12/#{start_date.year}")
  end

  def term_day?(date)
    date.strftime('%d/%m') == '31/12'
  end

  def days_count_of_a_term
    365
  end

  def days_count_of_a_term_for_display
    365
  end

  def calculate_next_payment_day(date)
    (date + 1.year).end_of_year
  end
end
