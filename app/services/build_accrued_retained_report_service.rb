# frozen_string_literal: true

require 'prawn'

class BuildAccruedRetainedReportService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Lint/SuppressedException
  def call(sub_investments, params, paid: false)
    investment_source = params[:investment_source] || []
    investment_status = params[:investment_status] || []
    date_from         = params[:date_from]
    date_to           = params[:date_to]
    payment_kind      = params[:payment_kind] || []
    total_usd         = { 'Accrued' => 0, 'Retained' => 0, 'Misc' => 0 }
    total_cad         = total_usd.clone
    payment_result    = []

    header = ['Sub Investment', 'Investment Source', 'Currency']

    header += ['Accrued', 'Accrued Check #'] if payment_kind.include?('Accrued')

    header += ['Interest Reserve', 'Interest Reserve Check #'] if payment_kind.include?('Retained')

    header += ['Misc', 'Misc Check #'] if payment_kind.include?('Misc')

    payment_result << header

    date_range = ''
    begin
      date_from = date_from.to_date
      date_to = date_to.to_date
      date_range = "#{date_from.strftime('%b %d, %Y')} - #{date_to.strftime('%b %d, %Y')}"
    rescue
    end

    sub_investments.each do |s|
      next if investment_source&.exclude?(s.investment.investment_source_id.to_s)
      next if investment_status&.exclude?(s.investment_status.name.downcase)

      row = [s.name, s.investment.investment_source.name, s.currency]
      current = {}

      payment_kind.each do |payment_type|
        current[payment_type] = s.sum_of_payments(date_from, date_to, payment_type, paid: paid)
        current[payment_type] = 0 if current[payment_type].round(2).zero?
      end

      next if all_zero?(current)

      payment_kind.each do |payment_type|
        row += [number_to_currency(current[payment_type], precision: 2), s.check_no(date_from, date_to, paid, payment_type)]
      end

      payment_result << row

      if s.currency == 'USD'
        payment_kind.each { |payment_type| total_usd[payment_type] += current[payment_type] }
      else
        payment_kind.each { |payment_type| total_cad[payment_type] += current[payment_type] }
      end
    end

    total_cad_row = ['Total CAD', nil, 'CAD']
    total_usd_row = ['Total USD', nil, 'USD']
    payment_kind.each do |payment_type|
      total_cad_row += [number_to_currency(total_cad[payment_type], precision: 2), '']
      total_usd_row += [number_to_currency(total_usd[payment_type], precision: 2), '']
    end

    payment_result << total_cad_row
    payment_result << total_usd_row
    width  = 460
    height = 100

    Prawn::Document.new(top_margin: 20) do
      font_size 9

      image Rails.public_path.join('icic.jpg').to_s, width: 540

      move_down MOVE_DOWN_POINT

      bounding_box([40, cursor], width: width, height: height) do
        stroke do
          polygon [0, 0], [width, 0], [width, height], [0, height]
        end

        move_down MOVE_DOWN_POINT * 2

        text "Report was generated with the following details on #{Time.zone.today}", align: :center, color: '000000', size: 12, style: :bold

        move_down MOVE_DOWN_POINT * 1

        text "Date range used to generate report - #{date_range}", align: :center, color: '000000', size: 10
        text "Payment Types - #{payment_kind.join(', ')}", align: :center, color: '000000', size: 10
        text "#{paid ? 'Paid' : 'Pending'} Payments", align: :center, color: '000000', size: 10
      end

      move_down MOVE_DOWN_POINT * 3

      # if payment_kind.include?('Accrued') && payment_kind.include?('Retained')
      #   column_widths = [180, 180, 60, 60, 60]
      # else
      #   column_widths = [180, 180, 60, 120]
      # end
      case payment_kind.length
      when 3
        column_widths = [105, 105, 46, 49, 49, 49, 49, 44, 44]
      when 2
        column_widths = [160, 160, 40, 40, 40, 50, 50]
      when 1
        column_widths = [180, 180, 60, 60, 60]
      end

      table(payment_result, header: true, column_widths: column_widths, cell_style: { size: 6, border_widths: [0, 0, 1, 0], align: :center }) # 55

      move_down MOVE_DOWN_POINT * 3

      text 'Innovation Capital Investment Corp - Van Haren Investment Corp - Innovation Capital Investment USA, Inc', align: :center, color: '000000', size: 10
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 10
      text 'kvh@innovationcic.com - je@innovationcic.com - rvh@innovationcic.com', align: :center, color: '000000', size: 10
      text '+1 604 727 6328 - +1 604 312 6653 - +1 778 999 3141', align: :center, color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 3

      text 'Thank you, ICIC', align: :center, color: '000000', size: 10
    end
  end
  # rubocop:enable Lint/SuppressedException
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def all_zero?(current)
    current.values.all?(&:zero?)
  end
end
