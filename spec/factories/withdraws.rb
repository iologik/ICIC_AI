# frozen_string_literal: true

# == Schema Information
#
# Table name: withdraws
#
#  id                    :integer          not null, primary key
#  amount                :decimal(12, 2)
#  check_no              :string(255)
#  due_date              :date
#  is_notify_investor    :boolean
#  is_notify_to_investor :boolean
#  is_transfer           :boolean          default(FALSE)
#  paid                  :boolean          default(FALSE)
#  paid_date             :date
#  type                  :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  admin_user_id         :integer
#  sub_investment_id     :integer
#  transfer_from_id      :integer
#  transfer_to_id        :integer
#
# Indexes
#
#  index_withdraws_on_admin_user_id      (admin_user_id)
#  index_withdraws_on_sub_investment_id  (sub_investment_id)
#  index_withdraws_on_transfer_from_id   (transfer_from_id)
#  index_withdraws_on_transfer_to_id     (transfer_to_id)
#
FactoryBot.define do
  factory :withdraw do
    amount { 100 }
    sub_investment
    admin_user
  end
end
