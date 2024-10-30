# frozen_string_literal: true

require 'prawn'

class BuildWithdrawService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  def call(withdraw)
    withdraw_rows = withdraw_data(withdraw)
    Prawn::Document.new(top_margin: 20) do
      font_size 7

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT * 2

      text "This Report was generated with the following details on #{Time.zone.today}", align: :center,
                                                                                         color: '000000', size: 12, style: :bold

      move_down MOVE_DOWN_POINT

      table(withdraw_rows, column_widths: [50, 40, 45, 80, 90, 40, 55, 55, 55], cell_style: { border_widths: [0, 0, 1, 0], align: :center }) # 55

      move_down MOVE_DOWN_POINT * 3

      text 'Innovation Capital Investment Corp - Van Haren Investment Corp - Innovation Capital Investment USA, Inc',
           align: :center, color: '000000', size: 8
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 8
      text 'kvh@innovationcic.com - je@innovationcic.com - rvh@innovationcic.com', align: :center, color: '000000',
                                                                                   size: 8
      text '+1 604 727 6328 - +1 604 312 6653 - +1 778 999 3141', align: :center, color: '000000', size: 8

      move_down MOVE_DOWN_POINT * 3

      text 'Thank you, ICIC', align: :center, color: '000000', size: 8
    end
  end

  def withdraw_data(withdraw)
    rows = [['Date', 'Check Number', 'Account Type', 'Investor Source', 'Sub-investment', 'Currency', 'Withdraw Amount',
             'Previous Principal', 'Current Principal']]
    rows << [withdraw.due_date,
             withdraw.check_no,
             withdraw.sub_investment.account&.name,
             withdraw.sub_investment.investment.investment_source.name,
             withdraw.sub_investment.name,
             withdraw.sub_investment.currency,
             number_to_currency(withdraw.amount, precision: 2),
             number_to_currency(withdraw.sub_investment.amount, precision: 2),
             number_to_currency(withdraw.sub_investment.amount - withdraw.amount, precision: 2)]
  end
  # rubocop:enable Metrics/AbcSize
end
