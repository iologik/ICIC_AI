# frozen_string_literal: true

require 'prawn'

class BuildAgreementService < BaseService
  MOVE_DOWN_POINT = 7

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def call(sub_investment)
    sub_investment.interest_periods.order('effect_date desc').first
    number_to_percentage((sub_investment.ownership_amount / (sub_investment.investment.amount + sub_investment.investment.cash_reserve)) * 100)

    number_to_currency(sub_investment.current_amount)
    number_to_currency(sub_investment.ownership_amount)

    interest_periods = [['Date', "Interest Per Annum<br /><font size=\"9\">Paid out: (#{sub_investment.scheduled})</font>", 'Accrued']]
    sub_investment.interest_periods.each do |i|
      interest_periods << [i.effect_date, number_to_percentage(i.per_annum), number_to_percentage(i.accrued_per_annum)]
    end

    file_name = "#{sub_investment.id}-#{sub_investment.name.parameterize}-agreement.pdf"
    descrpt1  = sub_investor_description1
    descrpt2  = sub_investor_description2
    Prawn::Document.generate(file_name, page_size: 'A3', top_margin: 20) do
      font_size 10
      default_leading 3

      image Rails.public_path.join('icic.jpg').to_s, width: 780, position: :center

      move_down MOVE_DOWN_POINT

      text 'Innovation Capital Investment Corp, Van Haren Investment Corp, Innovation Capital Investment USA, Inc', align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text '3830 Bayridge Avenue , West Vancouver, B.C.  V7V3J2', align: :center, color: '000000', size: 10
      move_down MOVE_DOWN_POINT * 0.3
      text 'kvh@innovationcic.com +1 604 727 6328     rvh@innovationcic.com +1 778 999 3141', align: :center, color: '000000', size: 10
      text 'je@innovationcic.com - +1 604 312 6653', align: :center, color: '000000', size: 10

      move_down MOVE_DOWN_POINT * 2

      text '<b>Loan Agreement</b>', align: :center, size: 20, inline_format: true

      move_down MOVE_DOWN_POINT * 2
      text 'BETWEEN:'

      investment_source_name = sub_investment&.investment&.investment_source&.name || 'Innovation Capital Investment Corp'
      text_box "#{investment_source_name} (<b>\"ICIC Company\"</b>)", at: [40, cursor], inline_format: true

      move_down MOVE_DOWN_POINT * 3

      text 'AND'
      text_box "#{sub_investment.admin_user.reverse_name}  (<b>\"Sub-Investor\"</b>)", at: [40, cursor], inline_format: true
      move_down MOVE_DOWN_POINT * 2
      addr = "#{sub_investment.admin_user.address} #{sub_investment.admin_user.city} #{sub_investment.admin_user.province} #{sub_investment.admin_user.country}"
      text_box addr, at: [40, cursor]
      move_down MOVE_DOWN_POINT * 2

      y_position = cursor - (MOVE_DOWN_POINT * 3)

      bounding_box([0, y_position], width: 380) do
        text "RE:         #{sub_investment.investment.legal_name}  (<b>\"Project\"</b>)", inline_format: true
        text_box sub_investment.investment.address.to_s + " #{sub_investment.investment.postal_code}", at: [40, cursor]
        move_down MOVE_DOWN_POINT * 4
      end

      bounding_box([390, y_position], width: 260) do
        text "Referred to as: #{sub_investment.investment.name}"
        text "Project Location: #{sub_investment.investment.location}"
      end

      # table
      move_down MOVE_DOWN_POINT * 5
      exchange_rate = if sub_investment.different_currency? && sub_investment.exchange_rate
                        format '%.3f', sub_investment.exchange_rate
                      else
                        (Prawn::Text::NBSP * 16).to_s
                      end
      text "Currency exchange rate if applicable is: #{exchange_rate}", align: :right

      investment = sub_investment.investment
      investment_data = []
      # we use current amount in this table

      investment_data << ['ICIC', { content: 'Total amount committed to Project by ICIC Company as per Project Outline:', colspan: 3 },
                          { content: investment.currency.to_s, align: :center }, BuildAgreementService.number_to_currency(investment.icic_committed_capital)]

      investment_data << ['SUB-INVESTOR', { content: "Term of loan: #{sub_investment.months} months", colspan: 2, align: :center },
                          { content: 'Principal amount of loan:', align: :center }, { content: sub_investment.currency.to_s, align: :center },
                          BuildAgreementService.number_to_currency(sub_investment.current_amount)]
      investment_data << [{ content: "Origination Date: #{sub_investment.creation_date}", colspan: 2, align: :center },
                          { content: "Interest start date: #{sub_investment.creation_date}", colspan: 2, align: :center },
                          { content: "Loan end date: #{(sub_investment.creation_date || sub_investment.created_at.to_date) + sub_investment.months.months}", colspan: 2, align: :center }]
      table(investment_data, column_widths: [100, 160, 130, 140, 100, 120])

      # table
      move_down MOVE_DOWN_POINT * 4
      text 'Subject to the terms of this Agreement, ICIC will pay interest at the rate set out below:',
           inline_format: true, align: :center
      table(interest_periods, position: :center, column_widths: [160, 160, 160],
                              cell_style: { align: :center, inline_format: true })

      move_down MOVE_DOWN_POINT * 2
      text 'Accrued interest, if applicable as set forth above shall accrue during the term without compounding and shall be paid with repayment of Principal Amount.',
           inline_format: true

      move_down MOVE_DOWN_POINT * 2
      text 'The ICIC Company may prepay the whole or any portion of the Principal Amount at any time without notice or bonus, provided all interest accrued on any such Principal prepayment is paid concurrent with the Principal repayment.'
      move_down MOVE_DOWN_POINT * 2
      text descrpt1
      move_down MOVE_DOWN_POINT * 2
      text descrpt2
      move_down MOVE_DOWN_POINT * 2
      text "This loan agreement dated #{Time.zone.today} supersedes any other loan agreements for the Project - #{sub_investment.name}"

      cursor
      move_down MOVE_DOWN_POINT * 6

      text_box "<u>Acknowledged and agreed to this\t</u>", at: [590, cursor], inline_format: true
      move_down MOVE_DOWN_POINT * 8
      text_box "Signature of Sub-Investor<u>#{Prawn::Text::NBSP * 80}\t</u>", at: [0, cursor], inline_format: true
      text_box "<u>#{Prawn::Text::NBSP * 50}</u>", at: [590, cursor], inline_format: true

      move_down MOVE_DOWN_POINT * 10
      text_box "Signature of the ICIC-Company<u>#{Prawn::Text::NBSP * 72}\t</u>", at: [0, cursor], inline_format: true
      text_box "<u>#{Prawn::Text::NBSP * 50}</u>", at: [590, cursor], inline_format: true
    end

    file_name
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def sub_investor_description1
    'Sub-Investor acknowledges that he/she has read, understood and signed an ' \
      '“Acknowledgement of Investment Relationship”(the “Acknowledgement”) and agrees ' \
      'the terms of same apply to and form part of this Loan Agreement. Capitalized terms ' \
      'not defined in this Loan Agreement shall have the meanings ascribed thereto in the Acknowledgement.'
  end

  def sub_investor_description2
    'If the Sub-Investor herein is a Corporation, Trust, RRSP, RRIF or other entity, ' \
      'the person executing this Loan Agreement thereby represents to the Company that ' \
      'he/she has full power and authority to sign this Loan Agreement on behalf of such entity.'
  end
end
