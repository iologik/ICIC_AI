# frozen_string_literal: true

# == Schema Information
#
# Table name: borrowers
#
#  id         :integer          not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  email      :string(255)
#  company    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Borrower < ApplicationRecord
  validates :last_name, presence: true

  scope :order_by_name, -> { order(:last_name, :first_name) }

  def name
    "#{first_name} #{last_name}"
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(company created_at email first_name id last_name updated_at)
  end
end
