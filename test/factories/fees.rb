# frozen_string_literal: true

# == Schema Information
#
# Table name: fees
#
#  id                :bigint           not null, primary key
#  amount            :decimal(, )
#  collected         :boolean          default(FALSE)
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  investment_id     :bigint
#  sub_investment_id :bigint
#  withdraw_id       :bigint
#
# Indexes
#
#  index_fees_on_investment_id      (investment_id)
#  index_fees_on_sub_investment_id  (sub_investment_id)
#  index_fees_on_withdraw_id        (withdraw_id)
#
FactoryBot.define do
  factory :fee do
    sub_investment { nil }
    investment { nil }
    description { 'MyString' }
    amount { '9.99' }
  end
end
