# frozen_string_literal: true

require 'prawn'

class BuildPaymentsPDFService < BaseService
  include PaymentsFileDataGenerator

  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  def call(payments, is_user_payment: false)
    payment_result = payment_data(payments, is_user_payment)

    Prawn::Document.new(top_margin: 20, page_size: 'A3') do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 780

      move_down MOVE_DOWN_POINT * 3

      text "This Report was generated with the following details on #{Time.zone.today}", align: :center,
                                                                                         color: '000000', size: 15

      move_down MOVE_DOWN_POINT * 1

      table(payment_result, column_widths: [125, 160, 85, 85, 55, 60, 60, 65, 65], cell_style: { border_widths: [0, 0, 1, 0], align: :center }) # 55

      move_down MOVE_DOWN_POINT * 3

      text 'Innovation Capital Investment Corp - Van Haren Investment Corp - Innovation Capital Investment USA, Inc',
           align: :center, color: '000000', size: 10
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 10
      text 'kvh@innovationcic.com - je@innovationcic.com - rvh@innovationcic.com', align: :center, color: '000000',
                                                                                   size: 10
      text '+1 604 727 6328 - +1 604 312 6653 - +1 778 999 3141', align: :center, color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 3

      text 'Thank you, ICIC', align: :center, color: '000000', size: 10
    end
  end

  def payment_data(payments, is_user_payment)
    payments = payments.except(:limit, :offset)

    payments = payments.order(paid_date: :asc) if is_user_payment

    file_data, total_amount_cad, total_amount_usd = generate_file_data(payments)

    file_data << [nil, nil, nil, nil, nil, nil, nil, nil, nil]
    file_data << [nil, nil, nil, nil, nil, 'Total USD', number_to_currency(total_amount_usd, precision: 2), nil, nil]
    file_data << [nil, nil, nil, nil, nil, 'Total CAD', number_to_currency(total_amount_cad, precision: 2), nil, nil]
  end
  # rubocop:enable Metrics/AbcSize
end
