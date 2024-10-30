# frozen_string_literal: true

require 'prawn'

class BuildIncreaseService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  def call(increase)
    tb_data = table_data(increase)
    Prawn::Document.new(top_margin: 20) do
      font_size 7

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT * 2

      text "Report was generated with the following details on #{Time.zone.today}", align: :center, color: '000000', size: 12, style: :bold

      move_down MOVE_DOWN_POINT * 3

      table(tb_data, column_widths: [50, 40, 45, 80, 90, 40, 55, 55, 55], cell_style: { border_widths: [0, 0, 1, 0], align: :center }) # 55

      move_down MOVE_DOWN_POINT * 3

      text 'Innovation Capital Investment Corp - Van Haren Investment Corp - Innovation Capital Investment USA, Inc', align: :center, color: '000000', size: 8
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 8
      text 'kvh@innovationcic.com - je@innovationcic.com - rvh@innovationcic.com', align: :center, color: '000000', size: 8
      text '+1 604 727 6328 - +1 604 312 6653 - +1 778 999 3141', align: :center, color: '000000', size: 8

      move_down MOVE_DOWN_POINT * 3

      text 'Thank you, ICIC', align: :center, color: '000000', size: 8
    end
  end

  def table_data(increase)
    increase_result = [['Date', 'Check Number', 'Account Type', 'Investor Source', 'Sub-investment', 'Currency',
                        'Increase Amount', 'Previous Principal', 'Current Principal']]
    increase_result << [increase.due_date,
                        increase.check_no,
                        increase.sub_investment.account&.name,
                        increase.sub_investment.investment.investment_source.name,
                        increase.sub_investment.name,
                        increase.sub_investment.currency,
                        number_to_currency(increase.amount, precision: 2),
                        number_to_currency(increase.sub_investment.current_amount - increase.amount, precision: 2),
                        number_to_currency(increase.sub_investment.current_amount, precision: 2)]
  end
  # rubocop:enable Metrics/AbcSize
end
