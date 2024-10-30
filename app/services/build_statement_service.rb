# frozen_string_literal: true

require 'prawn'

class BuildStatementService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/ParameterLists
  # rubocop:disable Metrics/PerceivedComplexity
  def call(sub_investments, investment_source = [], investment_status = [], payment_kind = [], date_from = nil,
           date_to = nil)
    payment_result = [['Account Type', 'Sub Investment Name', 'Investment Source', 'Currency', 'Invested Funds',
                       'Interest P.A', 'Start Date', 'Estimated Completion', 'Paid Out', 'Funds Paid To Date']]
    usd_total_initial_amount = usd_total_paid_amount = 0
    cad_total_initial_amount = cad_total_paid_amount = 0
    date_range = ''

    sub_investments.each do |s|
      next if investment_source&.exclude?(s.investment.investment_source_id.to_s)
      next if investment_status&.exclude?(s.investment_status.name.downcase)

      currently_invested_funds = s.amount

      begin
        date_from  = date_from.to_date
        date_to    = date_to.to_date
        total_paid = s.payments.where(payment_kind: payment_kind, paid: true, paid_date: date_from..date_to).sum(:amount)
        date_range = "#{date_from.strftime('%b %d, %Y')} - #{date_to.strftime('%b %d, %Y')}"
      rescue
        total_paid = s.payments.where(payment_kind: payment_kind, paid: true).sum(:amount)
      end

      next if total_paid.zero?

      payment_result << [s.account&.name,
                         s.name,
                         s.investment.investment_source.name,
                         s.currency,
                         number_to_currency(currently_invested_funds, precision: 2),
                         number_to_percentage(s.per_annum, precision: 2),
                         s.start_date,
                         s.end_date,
                         s.scheduled,
                         number_to_currency(total_paid, precision: 2)]
      if s.currency == 'USD'
        usd_total_initial_amount += s.amount
        usd_total_paid_amount += total_paid
      else
        cad_total_initial_amount += s.amount
        cad_total_paid_amount += total_paid
      end
    end

    payment_result << ['Total CAD', nil, nil, 'CAD', number_to_currency(cad_total_initial_amount, precision: 2),
                       nil, nil, nil, nil, number_to_currency(cad_total_paid_amount, precision: 2)]
    payment_result << ['Total USD', nil, nil, 'USD', number_to_currency(usd_total_initial_amount, precision: 2),
                       nil, nil, nil, nil, number_to_currency(usd_total_paid_amount, precision: 2)]

    Prawn::Document.new(page_size: 'A3', top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 780

      move_down MOVE_DOWN_POINT

      bounding_box([40, cursor], width: 700, height: 120) do
        stroke do
          polygon [0, 0], [700, 0], [700, 120], [0, 120]
        end

        move_down MOVE_DOWN_POINT * 3

        text "Report was generated with the following details on #{Time.zone.today}", align: :center, color: '000000',
                                                                                      size: 12, style: :bold

        move_down MOVE_DOWN_POINT * 1

        text "Funds paid to date summed using - #{payment_kind.present? ? payment_kind.join(', ') : ''}",
             align: :center, color: '000000', size: 10

        move_down MOVE_DOWN_POINT * 2

        text "Date range used to generate report - #{date_range}", align: :center, color: '000000', size: 10
      end

      move_down MOVE_DOWN_POINT * 3

      table(payment_result, header: true, column_widths: [80, 110, 100, 60, 60, 70, 60, 70, 70, 80], cell_style: { size: 9, border_widths: [0, 0, 1, 0], align: :center }) # 55

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
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/ParameterLists
  # rubocop:enable Metrics/PerceivedComplexity
end
