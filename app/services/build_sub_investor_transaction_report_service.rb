# frozen_string_literal: true

require 'prawn'

class BuildSubInvestorTransactionReportService < BaseService
  attr_accessor :start_date, :end_date

  MOVE_DOWN_POINT = 7

  def call(sub_investor, date_from, date_to, currency, investment_sources)
    rows_data = tb_data(sub_investor, date_from, date_to, currency, investment_sources)

    { success: true, file: report_file(rows_data) }
  end

  def tb_data(sub_investor, date_from, date_to, currency, investment_sources)
    @start_date = Date.parse(date_from)
    @end_date   = Date.parse(date_to)

    resp = table_data_of sub_investor, currency, investment_sources
    return resp unless resp[:success]

    resp[:table_data]
  end

  def table_data_of(sub_investor, currency, investment_sources)
    header = [['Date', 'Investment Name', 'Event', 'Description', 'Reference', 'Credit / Debit', 'Balance', 'Currency']]

    resp = all_transactions(sub_investor, currency, investment_sources)
    if resp[:success]
      {
        success: true,
        table_data: header + resp[:transactions].reverse,
      }
    else
      resp
    end
  end

  def all_transactions(sub_investor, currency, investment_sources)
    investment_sources_ints = investment_sources.map(&:to_i)
    all_steps = sub_investor.sub_investments.reduce([]) do |total, sub_investment|
      if sub_investment.investment.investment_source_id.in?(investment_sources_ints)
        total + sub_investment.current_amount_steps_with_transaction
      else
        total
      end
    end

    transactions_result(currency, all_steps)
  end

  def transactions_result(currency, all_steps)
    success        = true
    wrong_trans    = []
    current_amount = 0
    sorted_steps   = all_steps.sort_by { |e| e.date || Date.new(0o000) }
    transactions   = sorted_steps.each_with_object([]) do |step, table_data|
      next unless step.sub_investment.currency == currency

      resp, amount   = process_step_transaction(step, wrong_trans, table_data, current_amount, currency)
      success        = false if resp == false
      current_amount = amount
    end

    if success
      { success: true, transactions: transactions }
    else
      { success: false, error_type: 'TRANSACTION_NO_PAID_DATE', transactions: wrong_trans }
    end
  end

  def process_step_transaction(step, wrong_transactions, table_data, current_amount, currency)
    trans_date = step.date
    if trans_date.nil?
      wrong_transactions.push(step.withdraw)
      return [false, current_amount]
    elsif trans_date <= end_date && trans_date >= start_date
      current_amount = add_to_table_data(table_data, step, current_amount, currency)
    end

    [success, current_amount]
  end

  def add_to_table_data(table_data, step, current_amount, currency)
    if step.in && step.in != 0
      current_amount += step.in
      table_data << row_data(step, number_to_currency(step.in).to_s, current_amount, currency)
    elsif step.out && step.out != 0
      current_amount -= step.out
      table_data << row_data(step, "(#{number_to_currency(step.out)})", current_amount, currency)
    end

    current_amount
  end

  def row_data(step, step_amount_str, current_amount, currency)
    action          = step.action.casecmp('withdraw').zero? ? 'Withdraw' : step.action
    withdraw_name   = step.withdraw&.name || ''
    check_no        = step.withdraw&.check_no || ''
    investment_name = step.sub_investment.name
    formatted_amt   = number_to_currency(current_amount).to_s
    [step.date, investment_name, action, withdraw_name, check_no, step_amount_str, formatted_amt, currency]
  end

  # rubocop:disable Metrics/AbcSize
  def report_file(rows_data)
    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT * 3

      text 'Investor Transaction Ledger', align: :center, color: '000000', size: 15

      move_down MOVE_DOWN_POINT * 1

      text "This Report was generated with the following details on #{Time.zone.today}", align: :center, color: '000000', size: 8

      move_down MOVE_DOWN_POINT * 1

      text sub_investor.name.to_s, align: :center, color: '000000', size: 12

      move_down MOVE_DOWN_POINT * 1

      table(rows_data, column_widths: [60, 90, 50, 60, 70, 80, 80, 50], cell_style: { border_widths: [0, 0, 1, 0], align: :left }) # 55

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
  # rubocop:enable Metrics/AbcSize
end
