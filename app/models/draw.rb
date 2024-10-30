# frozen_string_literal: true

# == Schema Information
#
# Table name: draws
#
#  id            :integer          not null, primary key
#  amount        :decimal(12, 2)
#  date          :date
#  description   :text
#  investment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Draw < ApplicationRecord
  attr_accessor :balance

  belongs_to :investment

  validates :amount, presence: true
  validates :date, presence: true

  after_destroy :decrease_investment_amount

  after_save :adjust_investment_amount

  private

  def decrease_investment_amount
    investment.amount -= amount
    investment.save!
  end

  def adjust_investment_amount
    # investment.amount += amount
    # investment.save!

    # unless new_record?
    #   previous_investment = Investment.find(investment_id_was)
    #   previous_investment.amount -= amount_was
    #   previous_investment.save!
    # end
    UpdateInvestmentStatsWorker.perform_async(investment_id)
  end
end
