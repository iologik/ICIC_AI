# frozen_string_literal: true

class BuildT5ReportCsvService < BaseService
  def call(reports, exchange_rate_usd_cad)
    CSV.generate do |csv|
      # add headers
      csv << ['Investment Source', 'Sub Investor', 'Address', 'Postal Code', 'PIN', 'Total USD', 'Exchange Rate',
              'Converted', 'Total CAD', 'SUM CAD']
      total_cad, total_usd = add_data(reports, csv, exchange_rate_usd_cad)
      csv << [nil, '', '', '', 'Total', number_to_currency(total_usd),
              exchange_rate_usd_cad, number_to_currency(exchange_rate_usd_cad * total_usd),
              number_to_currency(total_cad), number_to_currency((exchange_rate_usd_cad * total_usd) + total_cad)]
    end
  end

  def add_data(reports, csv, exchange_rate_usd_cad)
    total_cad = total_usd = 0
    reports.each do |report|
      csv << row(report, exchange_rate_usd_cad)
      total_cad += report['cad_amount'].to_f
      total_usd += report['usd_amount'].to_f
    end
    [total_cad, total_usd]
  end

  def row(report, exchange_rate_usd_cad)
    investor      = AdminUser.find(report['id'])
    converted_cad = (report['usd_amount'].to_f || 0) * exchange_rate_usd_cad
    row_result(report, investor, exchange_rate_usd_cad, converted_cad)
  end

  def row_result(report, investor, exchange_rate_usd_cad, converted_cad)
    [report['source_flag'], report['name'], report['address'], investor.postal_code, investor.pin, number_to_currency(report['usd_amount']),
     exchange_rate_usd_cad, number_to_currency(converted_cad), number_to_currency(report['cad_amount']),
     number_to_currency(converted_cad + report['cad_amount'].to_f)]
  end
end
