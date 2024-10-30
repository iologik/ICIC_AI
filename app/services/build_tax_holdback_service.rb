# frozen_string_literal: true

class BuildTaxHoldbackService < BaseService
  MOVE_DOWN_POINT = 7

  def call(reports)
    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT

      move_down MOVE_DOWN_POINT * 3

      table(investments_data(reports), column_widths: [140, 100, 100, 100, 100], cell_style: { border_widths: [1, 1, 1, 1] }) # 55
    end
  end

  def investments_data(reports)
    investments = [['Investment', 'Currency', 'Year', 'Holdback Fed', 'Holdback State']]
    total_holdback_fed = total_holdback_state = 0
    reports.each do |report|
      investments          << [report.name, report.currency, report.year, report.holdback_fed, report.holdback_state]
      total_holdback_fed   += report.holdback_fed.to_f
      total_holdback_state += report.holdback_state.to_f
    end
    investments << [nil, nil, 'Total', number_to_currency(total_holdback_fed), number_to_currency(total_holdback_state)]
  end
end
