# frozen_string_literal: true

module QuarterTerm
  def calculate_first_term(start_date)
    year = start_date.year
    terms = [
      Date.parse("31/03/#{year}"),
      Date.parse("30/06/#{year}"),
      Date.parse("30/09/#{year}"),
      Date.parse("31/12/#{year}"),
    ]
    terms.each do |term|
      return term if start_date < term
    end
  end

  def term_day?(date)
    date.strftime('%d/%m').in? ['31/03', '30/06', '30/09', '31/12']
  end

  def days_count_of_a_term
    91.25
  end

  def days_count_of_a_term_for_display
    91.25
  end

  def calculate_next_payment_day(date)
    (date + 3.months).end_of_month # call end_of_month, because 30/09 + 3 months will get 30/12
  end
end
