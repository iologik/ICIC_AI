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
FactoryBot.define do
  factory :investment_status do
    name { 'Active' }
  end
end
