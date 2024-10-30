# frozen_string_literal: true

# == Schema Information
#
# Table name: sub_investor_relationships
#
#  id            :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :integer
#  admin_user_id :integer
#
# Indexes
#
#  index_sub_investor_relationships_on_account_id  (account_id)
#
class SubInvestorRelationship < ApplicationRecord
  belongs_to :admin_user, optional: true
  belongs_to :account, class_name: 'AdminUser', optional: true

  def self.ransackable_associations(_auth_object = nil)
    %w(account admin_user)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(account_id admin_user_id created_at id updated_at)
  end
end
