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
class Fee < ApplicationRecord
  belongs_to :sub_investment
  belongs_to :investment
  belongs_to :withdraw

  scope :collected, -> { where(collected: true) }
  scope :uncollected, -> { where(collected: false) }

  def self.ransackable_associations(_auth_object = nil)
    %w(investment sub_investment withdraw)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(amount collected created_at description id investment_id sub_investment_id updated_at withdraw_id)
  end
end
