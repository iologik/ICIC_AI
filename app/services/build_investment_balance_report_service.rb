# frozen_string_literal: true

require 'prawn'

class BuildInvestmentBalanceReportService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  def call(investments, date)
    tb_data = table_data(investments)
    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT

      text 'Innovation Capital Investment Corp, Van Haren Investment Corp, Innovation Capital Investment USA, Inc', align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text 'kvh@innovationcic.com +1 604 727 6328     rvh@innovationcic.com +1 778 999 3141', align: :center, color: '000000', size: 10
      text 'je@innovationcic.com - +1 604 312 6653', align: :center, color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 3

      date = DateTime.parse(date)
      text "STATEMENT OF INVESTMENTS AS OF #{date.strftime("%B #{date.day.ordinalize} %Y")}", align: :left, color: '000000', size: 14
      move_down MOVE_DOWN_POINT * 1

      move_down MOVE_DOWN_POINT * 3

      table(tb_data, column_widths: [180, 80, 170, 50, 60], cell_style: { border_widths: [1, 1, 1, 1] })
    end
  end

  def table_data(investments)
    result = [['Name', 'Balance', 'Investment Source', 'Currency', 'Start Date']]

    total_cad = total_usd = 0

    investments.each do |investment|
      next if investment.balance.zero?

      result << [
        investment.name,
        number_to_currency(investment.balance),
        investment.investment_source.name,
        investment.currency,
        investment.start_date,
      ]

      total_cad += investment.balance if investment.currency == 'CAD'
      total_usd += investment.balance if investment.currency == 'USD'
    end

    result << ['Total CAD', number_to_currency(total_cad), nil, nil, nil]
    result << ['Total USD', number_to_currency(total_usd), nil, nil, nil]
  end
  # rubocop:enable Metrics/AbcSize
end
