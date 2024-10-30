# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Account < ApplicationRecord
  validates :name, presence: true

  def self.cash_account
    @cash_account ||= Account.find_by(name: 'CASH')
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(created_at id name updated_at)
  end
end
