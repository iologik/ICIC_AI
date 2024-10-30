# frozen_string_literal: true

class MonthPaymentLoan < AbstractPaymentLoan
  include MonthTerm

  private

  def payment_message(end_date, days)
    "Interest for #{end_date.strftime('%Y-%m-%d')} (calculated #{days} days)"
  end
end
