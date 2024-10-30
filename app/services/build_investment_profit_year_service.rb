# frozen_string_literal: true

require 'prawn'

class BuildInvestmentProfitYearService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def call(investment_profits, year)
    tb_data = payment_data(investment_profits, year)
    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT

      text 'Innovation Capital Investment Corp, Van Haren Investment Corp, Innovation Capital Investment USA, Inc',
           align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text 'kvh@innovationcic.com +1 604 727 6328     rvh@innovationcic.com +1 778 999 3141', align: :center, color: '000000', size: 10
      text 'je@innovationcic.com - +1 604 312 6653', align: :center, color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 3

      table(tb_data, column_widths: [96, 40, 40, 52, 52, 52, 52, 52, 52], cell_style: { border_widths: [1, 1, 1, 1], inline_format: true }) # 55
    end
  end

  def payment_data(investment_profits, year)
    payment_result = [['Investment', 'Year', 'Currency', 'Initial Amount', 'Current Amount', 'Revenue Income',
                       'Interest Paid Out', 'Net Income', 'Accrued Payable', 'Interest Reserve Payable', 'Net Net Income']]

    initial_amount_total = current_amount_total = gross_profit_total = all_paid_payments_amount = sub_balance = accrued_payable = retained_payable = net_income = 0
    investment_profits.each do |invest|
      initial_amount_total     += invest.ori_amount
      current_amount_total     += year == 'ALL' ? invest.amount : invest.distribution_by_year(year.to_i)
      gross_profit_total       += invest.revenue.to_f
      all_paid_payments_amount += invest.paid_out.to_f
      sub_balance              += invest.sub_balance.to_f
      accrued_payable          += invest.accrued_payable
      retained_payable         += invest.retained_payable
      net_income               += invest.net_income.to_f
      current_amount = year == 'ALL' ? number_to_currency(invest.amount, precision: 2) : number_to_currency(invest.distribution_by_year(year.to_i), precision: 2)

      payment_result << [invest.name, invest.year, invest.currency, invest.ori_amount, current_amount,
                         number_to_currency(invest.revenue), number_to_currency(invest.paid_out),
                         invest.sub_balance.negative? ? "<color rgb='EC4242'>#{number_to_currency(invest.sub_balance)}</color>" : number_to_currency(invest.sub_balance),
                         number_to_currency(accrued_payable), number_to_currency(retained_payable),
                         invest.net_income.negative? ? "<color rgb='EC4242'>#{number_to_currency(invest.net_income)}</color>" : number_to_currency(invest.net_income)]
    end

    payment_result << ['', '', 'Total', number_to_currency(initial_amount_total), number_to_currency(current_amount_total),
                       number_to_currency(gross_profit_total),
                       number_to_currency(all_paid_payments_amount),
                       sub_balance.negative? ? "<color rgb='EC4242'>#{number_to_currency(sub_balance)}</color>" : number_to_currency(sub_balance),
                       number_to_currency(accrued_payable),
                       number_to_currency(retained_payable),
                       net_income.negative? ? "<color rgb='EC4242'>#{number_to_currency(net_income)}</color>" : number_to_currency(net_income)]
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
end
