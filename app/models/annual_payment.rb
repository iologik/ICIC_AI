# frozen_string_literal: true

class AnnualPayment < AbstractPayment
  include AnnualTerm

  private

  def payment_message(_end_date, days)
    "Annually payment (calculated #{days} days)"
  end
end
