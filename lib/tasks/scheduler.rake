# frozen_string_literal: true

desc 'fetch latest exchange rate'
task fetch_exchange_rate: :environment do
  usd_to_cad_rate = exchange_rate 'USD'
  cad_to_usd_rate = exchange_rate 'CAD'
  ExchangeRate.create(date: Time.zone.today, usd_to_cad_rate: usd_to_cad_rate, cad_to_usd_rate: cad_to_usd_rate) if usd_to_cad_rate && cad_to_usd_rate
end

def exchange_rate(src)
  src = src.upcase
  target = src == 'USD' ? 'CAD' : 'USD'

  uri = URI.parse("https://api.exchangeratesapi.io/latest?access_key=#{ENV['EXCHANGERATE_API_KEY']}&base=#{src}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.get(uri.request_uri)

  data = response.body && response.body.length >= 2 ? JSON.parse(response.body) : nil

  data['rates'] && data['rates'][target] ? data['rates'][target] : nil
end

desc 'Update accrued amounts every day'
task update_accrued_retained_amounts_daily: :environment do
  SubInvestment.find_each do |sub_investment|
    sub_investment.update(current_accrued_amount: sub_investment.current_accrued, current_retained_amount: sub_investment.current_retained)
  end
end
