# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                :integer          not null, primary key
#  date              :date
#  description       :text
#  status            :string(255)
#  sub_investment_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Task < ApplicationRecord
  scope :due_to_next_month, lambda {
                              where('date >= ? and date <= ? and status = ?', Time.zone.today, Time.zone.today.at_end_of_month.next_month, ACTIVE).order('date asc')
                            }

  belongs_to :sub_investment

  ACTIVE = 'active'
  DONE = 'done'
  ALL_STATUS = [ACTIVE, DONE].freeze

  validates :date, presence: true
  validates :status, presence: true

  def self.ransackable_associations(_auth_object = nil)
    ['sub_investment']
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(created_at date description id status sub_investment_id updated_at)
  end
end
