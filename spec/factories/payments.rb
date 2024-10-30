# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                    :integer          not null, primary key
#  amount                :decimal(12, 2)
#  check_no              :string(255)
#  currency              :string(255)
#  due_date              :date
#  investment_name       :string
#  is_resend_statement   :boolean
#  memo                  :text
#  paid                  :boolean          default(FALSE), not null
#  paid_date             :date
#  payment_kind          :string(255)
#  rate                  :decimal(, )
#  remark                :text
#  source_flag           :string(255)
#  start_date            :date
#  sub_investment_amount :decimal(12, 2)
#  sub_investor_name     :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  admin_user_id         :integer
#  sub_investment_id     :integer
#  withdraw_id           :integer
#
# Indexes
#
#  index_payments_on_admin_user_id      (admin_user_id)
#  index_payments_on_sub_investment_id  (sub_investment_id)
#  index_payments_on_withdraw_id        (withdraw_id)
#
FactoryBot.define do
  factory :payment do
    due_date { Date.parse('2012-01-05') }
    paid_date { Date.parse('2012-01-04') }
    paid { false }
    amount { 100 }
    memo { 'Interest' }
    payment_kind { Payment::Type_Interest }
    check_no { nil }

    admin_user
    sub_investment
  end
end
