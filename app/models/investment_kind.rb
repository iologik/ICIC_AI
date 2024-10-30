# frozen_string_literal: true

# == Schema Information
#
# Table name: investment_kinds
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class InvestmentKind < ApplicationRecord
  # attr_accessible :name
  has_many :investments, dependent: :destroy
  validates :name, presence: true

  def self.ransackable_associations(_auth_object = nil)
    ['investments']
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(created_at id name updated_at)
  end
end
