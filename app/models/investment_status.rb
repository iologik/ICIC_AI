# frozen_string_literal: true

# == Schema Information
#
# Table name: investment_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class InvestmentStatus < ApplicationRecord
  validates :name, presence: true

  # SubInvestments also use this Status

  def self.active_status
    Rails.cache.fetch('active_investment_status', expires_in: 1.hour) do
      InvestmentStatus.where(name: 'Active').first_or_create
    end
  end

  def self.archive_status
    Rails.cache.fetch('archived_investment_status', expires_in: 1.hour) do
      InvestmentStatus.where(name: 'Archived').first_or_create
    end
  end

  def self.future
    Rails.cache.fetch('future_investment_status', expires_in: 1.hour) do
      InvestmentStatus.where(name: 'Future').first_or_create
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(created_at id name updated_at)
  end
end
