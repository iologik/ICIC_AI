# frozen_string_literal: true

require 'prawn'

class BuildInvestmentReportService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def call(investment, start_date_str = nil, end_date_str = nil, transaction_type = [])
    report_sections = {}

    start_date = DateTime.parse(start_date_str)
    end_date   = DateTime.parse(end_date_str)
    date_range_str = "#{start_date_str} - #{end_date_str}"
    date_range = (start_date..end_date)

    template = {}
    transaction_type.each do |key|
      template[key] = 0
    end

    investment.distribution_draws.each do |transaction|
      trans_year = transaction.date.year
      trans_year_str = trans_year.to_s

      next unless date_range.include?(transaction.date)

      report_sections[trans_year_str] = template.clone unless report_sections[trans_year_str]

      if transaction.instance_of?(::Distribution)
        report_sections[trans_year_str]['FED']               += (transaction.withholding_tax   || 0) if 'FED'.in?(transaction_type)
        report_sections[trans_year_str]['GROSS PROFIT']      += (transaction.holdback_state    || 0) if 'GROSS PROFIT'.in?(transaction_type)
        report_sections[trans_year_str]['CASH RESERVE']      += (transaction.cash_reserve      || 0) if 'CASH RESERVE'.in?(transaction_type)
        report_sections[trans_year_str]['NET CASH']          += (transaction.net_cash          || 0) if 'NET CASH'.in?(transaction_type)
        report_sections[trans_year_str]['RETURN OF CAPITAL'] += (transaction.return_of_capital || 0) if 'RETURN OF CAPITAL'.in?(transaction_type)
      elsif transaction.instance_of?(::Draw)
        report_sections[trans_year_str]['CAPITAL INVESTED']  += (transaction.amount || 0) if 'CAPITAL INVESTED'.in?(transaction_type)
      end
    end

    sorted_report   = report_sections.sort.to_h
    report_text_arr = {}
    sorted_report.each do |year, report_details|
      report_text = []
      report_details.each do |key, value|
        report_text.push "#{key} All #{year} #{key} #{number_to_currency(value, precision: 2)}"
      end
      report_text_arr[year] = report_text
    end

    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT

      text "This report was generated with the following details on #{Time.zone.today}", align: :center,
                                                                                         color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 1

      bounding_box([40, cursor], width: 460, height: 60) do
        stroke do
          polygon [0, 0], [460, 0], [460, 60], [0, 60]
        end

        move_down MOVE_DOWN_POINT * 2

        text "Date range used to generate report - #{date_range_str}", align: :center, color: '000000', size: 10
      end

      move_down MOVE_DOWN_POINT * 3

      # start report details

      report_text_arr.each do |year, report_details|
        text "Investment #{investment.name} at #{year}"

        report_details.each do |report_txt|
          text report_txt
        end

        move_down MOVE_DOWN_POINT * 3
      end

      move_down MOVE_DOWN_POINT * 3

      text 'Innovation Capital Investment Corp - Van Haren Investment Corp - Innovation Capital Investment USA, Inc',
           align: :center, color: '000000', size: 8
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 8
      text 'kvh@innovationcic.com - je@innovationcic.com - rvh@innovationcic.com', align: :center, color: '000000',
                                                                                   size: 8
      text '+1 604 727 6328 - +1 604 312 6653 - +1 778 999 3141', align: :center, color: '000000', size: 8

      # end report details

      move_down MOVE_DOWN_POINT * 3

      text 'Thank you, ICIC', align: :center, color: '000000', size: 10
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
