# frozen_string_literal: true

# == Schema Information
#
# Table name: investment_sources
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  pin        :string
#  priority   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :investment_source do
    name { 'icic' }
  end
end
