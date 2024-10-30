# frozen_string_literal: true

# == Schema Information
#
# Table name: variables
#
#  id         :bigint           not null, primary key
#  key        :string
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :variable do
    key { 'MyString' }
    value { 'MyString' }
  end
end
