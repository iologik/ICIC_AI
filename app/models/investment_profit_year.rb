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
class InvestmentProfitYear < Investment
  attr_accessor :year, :revenue, :paid_out

  class << self
    def currencies_and_years
      sql = "select currency, date_part('year', start_date) as year, count(1) from investments group by currency, year order by year desc, currency asc"
      ApplicationRecord.connection.execute(sql).to_a
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def find_by_currency_and_year(currency, year)
      if currency == 'ALL' && year == 'ALL'
        all_currencies_and_years
      elsif currency == 'ALL'
        all_currencies_and_years.select { |x| x.year == year }
      elsif year == 'ALL'
        all_currencies_and_years.select { |x| x.currency == currency }
      else
        all_currencies_and_years(currency, year).select { |x| x.currency == currency && x.year == year }
      end
    end

    def all_currencies_and_years(currency = nil, year = nil)
      distribution_investment_hash = distribution_hash(currency, year)
      payment_investment_hash = payment_hash(currency, year)

      array = []
      (distribution_investment_hash.keys + payment_investment_hash.keys).uniq.each do |key|
        a = distribution_investment_hash[key] || {}
        b = payment_investment_hash[key] || {}
        # array << OpenStruct.new(a.merge(b))
        array << build_with_hash(a.merge(b))
      end

      array.sort_by { |e| [e.name, e.year] }
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def all_distribution_investments
      distribution_sql = %(select date_part('year', date) as year, investment_id, sum(gross_profit) as revenue, investments.currency
            from distributions
            inner join investments on distributions.investment_id = investments.id
            group by year, investment_id, investments.name, investments.currency
            order by investment_id)
      ApplicationRecord.connection.execute(distribution_sql)
    end

    def distribution_investments_by_currency_and_year(currency, year)
      distribution_sql = %(select date_part('year', date) as year, investment_id, sum(gross_profit) as revenue, investments.currency
            from distributions
            inner join investments on distributions.investment_id = investments.id
            where investments.currency = '#{currency}'
            and date_part('year', date) = '#{year}'
            group by year, investment_id, investments.name, investments.currency
            order by investment_id)
      sanitized_sql = ActionController::Base.helpers.sanitize(distribution_sql)
      ApplicationRecord.connection.execute(sanitized_sql)
    end

    def distribution_hash(currency = nil, year = nil)
      distribution_investments =
        if currency && year
          distribution_investments_by_currency_and_year(currency, year)
        else
          all_distribution_investments
        end

      distribution_investment_hash = {}
      distribution_investments.each do |investment|
        investment_id = investment['investment_id']
        year = investment['year']
        currency = investment['currency']
        distribution_investment_hash["#{investment_id}-#{year}-#{currency}"] = investment
      end
      distribution_investment_hash
    end

    def all_payment_investments
      payment_sql = %(
                    select date_part('year', due_date) as year, investments.id as investment_id, string_agg(CAST(payments.id as text), ',') as payment_ids, investments.currency
                    from payments
                    inner join sub_investments on payments.sub_investment_id = sub_investments.id
                    inner join investments on sub_investments.investment_id = investments.id
                    where payment_kind in ('Interest', 'AMF', 'Accrued', 'Retained')
                    and paid = 't'
                    group by year, investments.id, investments.name, investments.currency
                    )
      ApplicationRecord.connection.execute(payment_sql)
    end

    def payment_investments_by_currency_and_year(currency, year)
      payment_sql = %(
                    select date_part('year', due_date) as year, investments.id as investment_id, string_agg(CAST(payments.id as text), ',') as payment_ids, investments.currency
                    from payments
                    inner join sub_investments on payments.sub_investment_id = sub_investments.id
                    inner join investments on sub_investments.investment_id = investments.id
                    where payment_kind in ('Interest', 'AMF', 'Accrued', 'Retained')
                    and paid = 't'
                    and investments.currency = '#{currency}'
                    and date_part('year', due_date) = '#{year}'
                    group by year, investments.id, investments.name, investments.currency
                    )
      sanitized_sql = ActionController::Base.helpers.sanitize(payment_sql)
      ApplicationRecord.connection.execute(sanitized_sql)
    end

    def payment_hash(currency = nil, year = nil)
      payment_investments =
        if currency && year
          payment_investments_by_currency_and_year(currency, year)
        else
          all_payment_investments
        end

      payment_investment_hash = {}
      payment_investments.each do |investment|
        next unless (investment_id = investment['investment_id'])

        paid_out = Payment.find(investment['payment_ids'].split(',')).sum(&:ownership_amount)
        year = investment['year']
        currency = investment['currency']
        payment_investment_hash["#{investment_id}-#{year}-#{currency}"] = investment.merge({ 'paid_out' => paid_out })
      end
      payment_investment_hash
    end

    def build_with_hash(hash)
      investment = InvestmentProfitYear.find(hash['investment_id'])
      investment.year = hash['year']
      investment.revenue = hash['revenue']
      investment.paid_out = hash['paid_out']
      investment
    end
  end

  def sub_balance
    @sub_balance ||= revenue.to_f - paid_out.to_f
  end

  def net_income
    @net_income ||= revenue.to_f - paid_out.to_f - accrued_payable - retained_payable
  end
end
