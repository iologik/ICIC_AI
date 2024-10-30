# frozen_string_literal: true

class QuarterPaymentLoan < AbstractPayment
  include QuarterTerm

  private

  def payment_message(_end_date, days)
    "Quarterly payment (calculated #{days} days)"
  end
end
