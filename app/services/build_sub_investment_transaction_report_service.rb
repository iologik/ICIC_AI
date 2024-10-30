# frozen_string_literal: true

require 'prawn'

class BuildSubInvestmentTransactionReportService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def call(sub_investment, date_from = nil, date_to = nil)
    start_date = Date.parse(date_from)
    end_date   = Date.parse(date_to)
    sub_investment_transactions = [['ID', 'Due Date', 'Name', 'Amount', 'Check No']]
    sub_investment.withdraws.order(due_date: :asc).each do |transaction|
      sub_investment_transactions << [
        transaction.id,
        transaction.due_date,
        transaction.name,
        transaction.amount,
        transaction.check_no,
      ]
    end

    sub_investment_events = [%w(Date Description)]
    sub_investment.events.order('created_at asc').each do |event|
      sub_investment_events << [event.date, event.description]
    end

    wrong_transactions = []
    sub_investment_balance = [['Date', 'Event', 'Description', 'Reference', 'Credit / Debit', 'Balance', 'Currency']]
    steps = amount_steps_of sub_investment
    steps.reverse_each do |step|
      trans_date = step.date
      if trans_date.nil?
        wrong_transactions << step.withdraw
        next
      end

      next if trans_date < start_date || trans_date > end_date

      if step.in && step.in != 0
        sub_investment_balance << [
          step.date,
          step.action.casecmp('withdraw').zero? ? 'Withdraw' : step.action,
          step.withdraw ? step.withdraw.name : '',
          step.withdraw ? step.withdraw.check_no : '',
          number_to_currency(step.in).to_s,
          number_to_currency(step.balance).to_s,
          sub_investment.currency.to_s,
        ]
      end

      next unless step.out && step.out != 0

      sub_investment_balance << [
        step.date,
        step.action.casecmp('withdraw').zero? ? 'Withdraw' : step.action,
        step.withdraw ? step.withdraw.name : '',
        step.withdraw ? step.withdraw.check_no : '',
        "(#{number_to_currency(step.out)})",
        number_to_currency(step.balance).to_s,
        sub_investment.currency.to_s,
      ]
    end

    if wrong_transactions.any?
      return {
        success: false,
        error_type: 'TRANSACTION_NO_PAID_DATE',
        transactions: wrong_transactions,
      }
    end

    report_file = Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT * 3

      text 'Subinvestment Transaction Ledger', align: :center, color: '000000', size: 15

      move_down MOVE_DOWN_POINT * 1

      text "This Report was generated with the following details on #{Time.zone.today}", align: :center,
                                                                                         color: '000000', size: 8

      move_down MOVE_DOWN_POINT * 1

      text "#{sub_investment.admin_user.name} - #{sub_investment.name}", align: :center, color: '000000', size: 12

      move_down MOVE_DOWN_POINT * 1

      table(sub_investment_balance, column_widths: [60, 70, 110, 100, 70, 70, 60], cell_style: { border_widths: [0, 0, 1, 0], align: :left }) # 55

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
    {
      success: true,
      file: report_file,
    }
  end

  def amount_steps_of(sub_investment)
    current_amount = 0
    steps = []
    up_to_date = nil
    initial_description = sub_investment.initial_description
    ori_amount = sub_investment.ori_amount
    start_date = sub_investment.start_date
    withdraws = sub_investment.withdraws
    principal_payment = sub_investment.payments.where(payment_kind: Payment::Type_Principal).first
    principal_paid    = principal_payment&.paid
    steps << if sub_investment.transfer_from
               Obj.new(start_date,
                       "#{initial_description.presence || 'Initial amount'} - Transferred from #{sub_investment.transfer_from.name}", ori_amount, nil, ori_amount)
             else
               Obj.new(start_date, (initial_description.presence || 'Initial amount').to_s,
                       ori_amount, nil, ori_amount)
             end

    current_amount = ori_amount

    # steps << Obj.new(principal_payment.due_date, action, nil, withdraw.amount, current_amount)

    temp_steps = begin
      if up_to_date.present?
        withdraws.where('due_date <= ?', DateTime.parse(up_to_date)).to_a
      else
        withdraws.to_a
      end
    rescue
      withdraws.to_a
    end

    temp_steps << Obj.new(principal_payment.paid_date, 'Principal Paid', nil, principal_payment.amount, nil) if principal_paid && principal_payment.paid_date && (up_to_date.blank? || DateTime.parse(up_to_date) > principal_payment.paid_date)

    temp_steps.sort_by { |e| e.due_date || Date.new(0o000) }.each do |withdraw|
      if withdraw.instance_of?(Increase)
        action = if withdraw.is_transfer
                   'Transfer in'
                 else
                   'Increase'
                 end
        current_amount -= withdraw.real_amount
        steps << Obj.new(withdraw.due_date, action, withdraw.amount, nil, current_amount, withdraw)
      elsif withdraw.instance_of?(Withdraw) || withdraw.instance_of?(ReturnCapitalInvestor)
        action = if withdraw.is_transfer
                   'Transfer out'
                 else
                   'Withdraw'
                 end
        if (payment = Payment.payment_for_withdraw(withdraw))&.paid
          current_amount -= withdraw.real_amount
          steps << Obj.new(payment.paid_date, action, nil, withdraw.amount, current_amount, withdraw)
        end
      else # principal payment, Obj
        current_amount -= withdraw.out
        steps << Obj.new(withdraw.date, withdraw.action, withdraw.in, withdraw.out, current_amount, withdraw.withdraw)
      end
    end
    # return
    steps
  end

  class Obj
    attr_accessor :date, :action, :in, :out, :balance, :withdraw

    # rubocop:disable Metrics/ParameterLists
    def initialize(date, action, amount_in, amount_out, balance, withdraw = nil)
      @date = date
      @action = action
      @in = amount_in
      @out = amount_out
      @balance = balance
      @withdraw = withdraw
    end

    def to_key
      nil
    end

    def due_date
      date
    end
  end
  # rubocop:enable Metrics/ParameterLists
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
