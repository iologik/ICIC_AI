# frozen_string_literal: true

# == Schema Information
#
# Table name: sub_investments
#
#  id                        :integer          not null, primary key
#  amount                    :decimal(12, 2)
#  archive_date              :date
#  creation_date             :date
#  currency                  :string(255)
#  current_accrued_amount    :decimal(, )
#  current_retained_amount   :decimal(, )
#  description               :text
#  exchange_rate             :decimal(, )
#  initial_description       :text
#  is_notify_investor        :boolean
#  memo                      :string(120)
#  months                    :integer
#  name                      :string           default("")
#  ori_amount                :decimal(12, 2)
#  private_note              :text
#  referrand_amount          :float
#  referrand_one_time_amount :decimal(12, 2)
#  referrand_one_time_date   :date
#  referrand_percent         :float
#  referrand_scheduled       :string(255)
#  remote_agreement_url      :string
#  scheduled                 :string(255)
#  signed_agreement_url      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :integer
#  admin_user_id             :integer
#  envelope_id               :string
#  investment_id             :integer
#  investment_status_id      :integer
#  referrand_user_id         :integer
#  sub_investment_kind_id    :string
#  sub_investment_source_id  :string
#  transfer_from_id          :integer
#
# Indexes
#
#  index_sub_investments_on_account_id            (account_id)
#  index_sub_investments_on_admin_user_id         (admin_user_id)
#  index_sub_investments_on_investment_id         (investment_id)
#  index_sub_investments_on_investment_status_id  (investment_status_id)
#  index_sub_investments_on_transfer_from_id      (transfer_from_id)
#
FactoryBot.define do
  factory :sub_investment do
    months { 12 }
    amount { 1000 }
    scheduled { 'Monthly' }
    currency { 'USD' }
    investment
    admin_user
    investment_status

    interest_periods { [FactoryBot.build(:interest_period, effect_date: Date.parse('2013-01-05'))] }

    # just because a interest_period will be built after a sub_investment
  end
end
