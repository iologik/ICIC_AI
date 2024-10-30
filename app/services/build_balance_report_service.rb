# frozen_string_literal: true

require 'prawn'

class BuildBalanceReportService < BaseService
  MOVE_DOWN_POINT = 7

  def call(sub_investments, date, sort_by_subinvestment)
    if sort_by_subinvestment
      render_sorted_pdf(sub_investments, date)
    else
      render_non_sorted_pdf(sub_investments, date)
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def render_sorted_pdf(sub_investments, date)
    sub_investment_result = {}

    total_cad = total_usd = 0
    sub_investments.each do |sub_investment|
      next if sub_investment.balance.zero?

      investment = sub_investment.investment
      sub_investment_result[investment.id] ||= { 'INVESTMENT_NAME' => investment.name }
      sub_investment_result[investment.id][sub_investment.currency] ||= []
      sub_investment_result[investment.id][sub_investment.currency] << [
        sub_investment.admin_user.name,
        number_to_currency(sub_investment.balance),
        investment.investment_source.name,
        sub_investment.currency,
        sub_investment.start_date,
        sub_investment.end_date,
      ]

      sub_investment_result[investment.id]["#{sub_investment.currency}_TOTAL"] ||= 0
      sub_investment_result[investment.id]["#{sub_investment.currency}_TOTAL"] += sub_investment.balance
    end

    sub_investment_result.each do |_key, result|
      result['CAD'] << ['Total CAD', number_to_currency(result['CAD_TOTAL']), nil, nil, nil, nil] if result['CAD'].present?

      total_cad += result['CAD_TOTAL'] if result['CAD'].present?

      result['USD'] << ['Total USD', number_to_currency(result['USD_TOTAL']), nil, nil, nil, nil] if result['USD'].present?

      total_usd += result['USD_TOTAL'] if result['USD'].present?
    end

    total_cad = number_to_currency(total_cad)
    total_usd = number_to_currency(total_usd)

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
      text "STATEMENT OF INVESTMENTS AS OF #{date.strftime("%B #{date.day.ordinalize} %Y")}", align: :center, color: '000000', size: 14
      move_down MOVE_DOWN_POINT * 1

      sub_investment_result.each do |_key, result|
        move_down MOVE_DOWN_POINT * 3

        text "For : #{result['INVESTMENT_NAME']}", align: :left, color: '000000', size: 12, style: :bold

        move_down MOVE_DOWN_POINT * 1

        text 'INVESTMENTS IN CAD CURRENCY', align: :center, color: '000000', size: 12, style: :bold if result['CAD'].present?

        table(result['CAD'], column_widths: [150, 80, 140, 50, 60, 60], cell_style: { border_widths: [1, 1, 1, 1] }) if result['CAD'].present?

        move_down MOVE_DOWN_POINT * 1

        text 'INVESTMENTS IN USD CURRENCY', align: :center, color: '000000', size: 12, style: :bold if result['USD'].present?

        table(result['USD'], column_widths: [150, 80, 140, 50, 60, 60], cell_style: { border_widths: [1, 1, 1, 1] }) if result['USD'].present?
      end

      move_down MOVE_DOWN_POINT * 2
      text "Total CAD: #{total_cad}", size: 12, style: :bold
      text "Total USD: #{total_usd}", size: 12, style: :bold
    end
  end

  def render_non_sorted_pdf(sub_investments, date)
    sub_investments.map(&:admin_user).uniq

    sub_investment_result = {}

    total_cad = total_usd = 0

    sub_investments.each do |sub_investment|
      next if sub_investment.balance.zero?

      sub_investment_result[sub_investment.admin_user.id] ||= { 'INVESTOR_NAME' => sub_investment.admin_user.name }
      sub_investment_result[sub_investment.admin_user.id][sub_investment.currency] ||= []
      sub_investment_result[sub_investment.admin_user.id][sub_investment.currency] << [
        sub_investment.name,
        number_to_currency(sub_investment.balance),
        sub_investment.investment.investment_source.name,
        sub_investment.currency,
        sub_investment.start_date,
        sub_investment.end_date,
      ]

      sub_investment_result[sub_investment.admin_user.id]["#{sub_investment.currency}_TOTAL"] ||= 0
      sub_investment_result[sub_investment.admin_user.id]["#{sub_investment.currency}_TOTAL"] += sub_investment.balance
    end

    sub_investment_result.each do |_key, result|
      result['CAD'] << ['Total CAD', number_to_currency(result['CAD_TOTAL']), nil, nil, nil, nil] if result['CAD'].present?

      total_cad += result['CAD_TOTAL'] if result['CAD'].present?

      result['USD'] << ['Total USD', number_to_currency(result['USD_TOTAL']), nil, nil, nil, nil] if result['USD'].present?

      total_usd += result['USD_TOTAL'] if result['USD'].present?
    end

    total_cad = number_to_currency(total_cad)
    total_usd = number_to_currency(total_usd)

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
      text "STATEMENT OF INVESTMENTS AS OF #{date.strftime("%B #{date.day.ordinalize} %Y")}", align: :center, color: '000000', size: 14
      move_down MOVE_DOWN_POINT * 1

      sub_investment_result.each do |_key, result|
        move_down MOVE_DOWN_POINT * 3

        text "For : #{result['INVESTOR_NAME']}", align: :left, color: '000000', size: 12, style: :bold

        move_down MOVE_DOWN_POINT * 1

        text 'INVESTMENTS IN CAD CURRENCY', align: :center, color: '000000', size: 12, style: :bold if result['CAD'].present?

        table(result['CAD'], column_widths: [150, 80, 140, 50, 60, 60], cell_style: { border_widths: [1, 1, 1, 1] }) if result['CAD'].present?

        move_down MOVE_DOWN_POINT * 1

        text 'INVESTMENTS IN USD CURRENCY', align: :center, color: '000000', size: 12, style: :bold if result['USD'].present?

        table(result['USD'], column_widths: [150, 80, 140, 50, 60, 60], cell_style: { border_widths: [1, 1, 1, 1] }) if result['USD'].present?
      end

      move_down MOVE_DOWN_POINT * 2
      text "Total CAD: #{total_cad}", size: 12, style: :bold
      text "Total USD: #{total_usd}", size: 12, style: :bold
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
