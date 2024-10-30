# frozen_string_literal: true

# == Schema Information
#
# Table name: investments
#
#  id                        :integer          not null, primary key
#  accrued_payable_amount    :decimal(, )
#  address                   :string(255)
#  all_paid_payments_amount  :decimal(, )
#  amount                    :decimal(12, 2)
#  archive_date              :date
#  cad_money_raised_amount   :decimal(12, 2)
#  cash_reserve_amount       :decimal(12, 2)
#  currency                  :string(255)
#  description               :text
#  distrib_cash_reserve      :decimal(, )
#  distrib_gross_profit      :decimal(, )
#  distrib_holdback_state    :decimal(, )
#  distrib_net_cash          :decimal(, )
#  distrib_return_of_capital :decimal(, )
#  distrib_withholding_tax   :decimal(, )
#  distribution_draw_amount  :decimal(, )
#  draw_amount               :decimal(, )
#  exchange_rate             :float
#  expected_return_percent   :float
#  fee_amount                :decimal(, )
#  fee_type                  :string
#  gross_profit_total_amount :decimal(, )
#  icic_committed_capital    :decimal(, )
#  image_url                 :string(255)
#  initial_description       :text
#  legal_name                :string(255)
#  location                  :string(255)
#  memo                      :string(120)
#  money_raised_amount       :decimal(12, 2)
#  name                      :string(255)
#  net_income_amount         :decimal(, )
#  ori_amount                :decimal(12, 2)
#  postal_code               :string
#  private_note              :text
#  retained_payable_amount   :decimal(, )
#  start_date                :date
#  sub_accrued_percent_sum   :decimal(, )
#  sub_amount_total          :decimal(, )
#  sub_balance_amount        :decimal(, )
#  sub_ownership_percent_sum :decimal(, )
#  sub_per_annum_sum         :decimal(, )
#  sub_retained_percent_sum  :decimal(, )
#  year_paid                 :decimal(, )
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  investment_kind_id        :integer
#  investment_source_id      :integer
#  investment_status_id      :integer
#
# Indexes
#
#  index_investments_on_investment_kind_id    (investment_kind_id)
#  index_investments_on_investment_source_id  (investment_source_id)
#  index_investments_on_investment_status_id  (investment_status_id)
#
class TaxHoldback < Investment
  attr_accessor :year, :holdback_fed, :holdback_state

  def self.tax_years
    sql = "select date_part('year', distributions.date) as year from distributions group by year order by year desc"
    ApplicationRecord.connection.execute(sql).pluck('year')
  end

  def self.tax_investments
    sql = "
    select investments.id, investments.name, investments.currency, date_part('year', distributions.date) as year, sum(withholding_tax) as withholding_tax, sum(holdback_state) as holdback_state
    from distributions
    left join investments on distributions.investment_id = investments.id
    group by investments.id, investments.name, investments.currency, date_part('year', distributions.date)
    order by investments.name, date_part('year', distributions.date)
    "
    investments = ApplicationRecord.connection.execute(sql)
    investments.map { |db_record| TaxHoldback.build_tax_holdback(db_record) }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def self.by_currency(currency, year)
    if currency == 'ALL' && year == 'ALL'
      tax_investments
    elsif currency == 'ALL'
      tax_investments.select { |x| x.year == year }
    elsif year == 'ALL'
      tax_investments.select { |x| x.currency == currency }
    else
      tax_investments.select { |x| x.currency == currency && x.year == year }
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def self.build_tax_holdback(db_record)
    tax_report = TaxHoldback.new
    tax_report.id = db_record['id']
    tax_report.name = db_record['name']
    tax_report.currency = db_record['currency']
    tax_report.year = db_record['year']
    tax_report.holdback_fed = db_record['withholding_tax']
    tax_report.holdback_state = db_record['holdback_state']
    tax_report
  end
end
