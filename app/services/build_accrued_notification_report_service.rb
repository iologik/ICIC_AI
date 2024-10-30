# frozen_string_literal: true

class BuildAccruedNotificationReportService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  def call(sub_investments, date)
    tb_data = table_data(sub_investments, date)
    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT * 3

      text "This Report was generated with the following details on #{Time.zone.today}", align: :center, color: '000000', size: 13

      move_down MOVE_DOWN_POINT * 2

      text 'Accrued Interest Balance Report - ', color: '000000', size: 12

      move_down MOVE_DOWN_POINT

      sub_investor_name = sub_investments.first.admin_user.name
      text "#{sub_investor_name}'s current accrued balance for the following projects on #{date} are listed below", color: '000000', size: 11

      move_down MOVE_DOWN_POINT * 2

      table(tb_data, column_widths: [62, 62, 151, 60, 65, 55, 85], cell_style: { border_widths: [0, 0, 1, 0], align: :center, size: 10 })

      move_down MOVE_DOWN_POINT * 3

      text 'Innovation Capital Investment Corp - Van Haren Investment Corp - Innovation Capital Investment USA, Inc', align: :center, color: '000000', size: 10
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 10
      text 'kvh@innovationcic.com - je@innovationcic.com - rvh@innovationcic.com', align: :center, color: '000000', size: 10
      text '+1 604 727 6328 - +1 604 312 6653 - +1 778 999 3141', align: :center, color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 3

      text 'Thank you, ICIC', align: :center, color: '000000', size: 10
    end
  end
  # rubocop:enable Metrics/AbcSize

  def table_data(sub_investments, date)
    sub_investment_results = [["Project\nStart Date", "Project\nEnd Date", 'Project Name', '% p.a', 'Invested Amount',
                               'Currency', 'Accrued Amount']]

    sub_investments.each do |sub_investment|
      sub_investment_results.push([
                                    sub_investment.start_date,
                                    sub_investment.end_date,
                                    sub_investment.name.gsub('\d{4}-\d{2}-\d{2}', ''),
                                    number_to_percentage(sub_investment.interest_periods.last.accrued_per_annum,
                                                         precision: 2),
                                    number_to_currency(sub_investment.amount, precision: 2),
                                    sub_investment.currency,
                                    number_to_currency(sub_investment.current_accrued_subinvest_currency(date),
                                                       precision: 2),
                                  ])
    end

    sub_investment_results
  end
end
