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
require 'rails_helper'

# rubocop:disable RSpec/ContextWording
RSpec.describe Investment do
  it { is_expected.to validate_presence_of(:amount) }

  it { is_expected.to belong_to(:investment_source) }

  it { is_expected.to belong_to(:investment_kind) }

  it { is_expected.to belong_to(:investment_status) }

  it { is_expected.to have_many(:sub_investments) }

  it { is_expected.to have_many(:distributions) }

  describe 'total' do
    context 'one investment' do
      subject { described_class.total }

      let!(:investment) { create(:investment) }

      before { investment.adjust_amount }

      it { is_expected.to eq(10_000) }
    end

    context 'two investments' do
      subject { described_class.total }

      let!(:investments) { create_list(:investment, 2) }

      before { investments.each(&:adjust_amount) }

      it { is_expected.to eq(20_000) }
    end
  end

  describe 'set original amount' do
    context 'with original amount' do
      subject do
        create(:investment, amount: 100, ori_amount: 200, start_date: Date.parse('2012-01-05')).ori_amount
      end

      it { is_expected.to eq(100) }
    end

    context 'without original amount' do
      subject { create(:investment, amount: 100, start_date: Date.parse('2012-01-05')).ori_amount }

      it { is_expected.to eq(100) }
    end
  end
end
# rubocop:enable RSpec/ContextWording
