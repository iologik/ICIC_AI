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
FactoryBot.define do
  factory :investment do
    name { 'investment name' }
    amount { 10_000 }
    ori_amount { 10_000 }
    start_date { Date.parse('2012-01-05') }
    currency { 'USD' }

    investment_source { InvestmentSource.first }
    investment_status { InvestmentStatus.first }
    investment_kind { InvestmentKind.first }
  end
end
