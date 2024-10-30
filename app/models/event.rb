# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  date              :date
#  description       :text
#  sub_investment_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Event < ApplicationRecord
  belongs_to :sub_investment
end
