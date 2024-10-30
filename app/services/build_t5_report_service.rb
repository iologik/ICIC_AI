# frozen_string_literal: true

require 'prawn'

class BuildT5ReportService < BaseService
  MOVE_DOWN_POINT = 7

  def call(reports)
    tb_data = payment_data(reports)
    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT

      move_down MOVE_DOWN_POINT * 3

      table(tb_data, column_widths: [75, 80, 40, 165, 60, 60, 60], cell_style: { border_widths: [1, 1, 1, 1] }) # 55
    end
  end

  # rubocop:disable Metrics/AbcSize
  def payment_data(reports)
    payment_result = [['Investment Source', 'Sub Investor', 'Address', 'Postal Code', 'PIN', 'Total CAD', 'Total USD']]
    total_cad = total_usd = 0
    reports.each do |report|
      investor = AdminUser.find(report['id'])
      payment_result << [
        report['source_flag'],
        report['name'],
        report['address'],
        investor.postal_code,
        investor.pin,
        number_to_currency(report['cad_amount']),
        number_to_currency(report['usd_amount']),
      ]
      total_cad += report['cad_amount'].to_f
      total_usd += report['usd_amount'].to_f
    end
    payment_result << [nil, '', '', '', 'Total', number_to_currency(total_cad), number_to_currency(total_usd)]
  end
  # rubocop:enable Metrics/AbcSize
end
