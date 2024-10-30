# frozen_string_literal: true

class BuildPaymentsCsvService < BaseService
  include PaymentsFileDataGenerator

  def call(payments, is_user_payment: false)
    payments = payments.except(:limit, :offset)

    payments = payments.order(paid_date: :asc) if is_user_payment

    CSV.generate do |csv|
      # add headers
      csv << [nil, 'INNOVATION CAPITAL INVESTMENT CORPORATION', nil, nil, nil, nil, nil, nil, nil]
      3.times { csv << [nil, nil, nil, nil, nil, nil, nil, nil, nil] }

      file_data, total_amount_cad, total_amount_usd = generate_file_data(payments)
      file_data.each do |row|
        csv << row
      end

      csv << [nil, nil, nil, nil, nil, 'Total USD', number_to_currency(total_amount_usd, precision: 2), nil]
      csv << [nil, nil, nil, nil, nil, 'Total CAD', number_to_currency(total_amount_cad, precision: 2), nil]
    end
  end
end
