# frozen_string_literal: true

require 'prawn'

class BuildSubDistributionService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  def call(sub_distribution, skip_make_payment_or_transfer)
    sub_distribution_result, balance_report = render_table_data(sub_distribution, skip_make_payment_or_transfer)

    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT * 2

      text "Report was generated with the following details on #{Time.zone.today}", align: :center, color: '000000',
                                                                                    size: 12, style: :bold

      move_down MOVE_DOWN_POINT * 3

      text 'Payment Report - ', color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 3

      table(sub_distribution_result, column_widths: [60, 110, 110, 110, 80, 70], cell_style: { border_widths: [0, 0, 1, 0], align: :center }) # 55

      move_down MOVE_DOWN_POINT * 3

      text 'Balance Report - ', color: '000000', size: 10

      table(balance_report, column_widths: [60, 110, 100, 100, 100, 70],
                            cell_style: { border_widths: [0, 0, 1, 0], align: :center })

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

  def render_table_data(sub_distribution, skip_make_payment_or_transfer)
    sub_distribution_result = [['Date', 'Investor Name', 'From', 'To', 'Amount', 'Check #']]
    sub_distribution_result << [sub_distribution.date,
                                sub_distribution.admin_user.name,
                                sub_distribution.sub_investment.name,
                                sub_distribution.transfer_to.name,
                                number_to_currency(sub_distribution.amount, precision: 2),
                                sub_distribution.check_no]

    source_report = [
      sub_distribution.date, sub_distribution.sub_investment.name, '',
      number_to_currency(sub_distribution.origin_amount, precision: 2),
      number_to_currency(sub_distribution.origin_amount - sub_distribution.amount, precision: 2),
      sub_distribution.check_no
    ]
    target_post_amnt = sub_distribution.target_amount

    inc_amount       = sub_distribution.amount
    source_currency  = sub_distribution.sub_investment.currency
    target_currency  = sub_distribution.transfer_to.currency
    if source_currency == 'CAD' && target_currency == 'USD'
      inc_amount *= Investment.latest_rate('CAD')
    elsif source_currency == 'USD' && target_currency == 'CAD'
      inc_amount /= Investment.latest_rate('CAD')
    end

    target_post_amnt += inc_amount unless skip_make_payment_or_transfer

    target_report = [
      sub_distribution.date, sub_distribution.transfer_to.name, '',
      number_to_currency(sub_distribution.target_amount, precision: 2),
      number_to_currency(target_post_amnt, precision: 2),
      sub_distribution.check_no
    ]
    balance_report = [['', 'Project Name', 'Investment Source', 'Previous Balance', 'Updated Balance', 'Check #'], source_report, target_report]

    [sub_distribution_result, balance_report]
  end
  # rubocop:enable Metrics/AbcSize
end
