# frozen_string_literal: true

require 'prawn'

class BuildInvestmentSubDistributionsService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  def call(investment_sub_distributions)
    tb_data = payment_data(investment_sub_distributions)
    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT

      text 'Innovation Capital Investment Corp, Van Haren Investment Corp, Innovation Capital Investment USA, Inc', align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text 'kvh@innovationcic.com +1 604 727 6328     rvh@innovationcic.com +1 778 999 3141', align: :center,
                                                                                              color: '000000', size: 10
      text 'je@innovationcic.com - +1 604 312 6653', align: :center, color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 3

      table(tb_data, column_widths: [320, 110, 110], cell_style: { border_widths: [1, 1, 1, 1] }) # 55
    end
  end

  def payment_data(investment_sub_distributions)
    payment_result = [['Investment', 'Sub Distribution CAD', 'Sub Distribution USD']]

    cad_sub_distribution = usd_sub_distribution = 0
    investment_sub_distributions.each do |invest|
      if invest.currency == 'CAD'
        cad_sub_distribution += invest.sub_distribution_amount
        payment_result << [invest.name,
                           number_to_currency(invest.sub_distribution_amount), nil]
      else
        usd_sub_distribution += invest.sub_distribution_amount
        payment_result << [invest.name,
                           nil, number_to_currency(invest.sub_distribution_amount)]
      end
    end

    payment_result << ['Total', number_to_currency(cad_sub_distribution), number_to_currency(usd_sub_distribution)]
  end
  # rubocop:enable Metrics/AbcSize
end
