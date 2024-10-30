# frozen_string_literal: true

# == Schema Information
#
# Table name: distributions
#
#  id                :integer          not null, primary key
#  return_of_capital :decimal(12, 2)
#  gross_profit      :decimal(12, 2)
#  date              :date
#  description       :text
#  investment_id     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  withholding_tax   :decimal(12, 2)
#  holdback_state    :decimal(12, 2)
#  cash_reserve      :decimal(12, 2)
#
class Distribution < ApplicationRecord
  # amount is return of capital

  attr_accessor :balance

  belongs_to :investment

  validates :return_of_capital, numericality: true, presence: true # amount must be greater than or equal to 0
  validates :withholding_tax, numericality: true, presence: true # amount must be greater than or equal to 0
  validates :gross_profit, numericality: true, presence: true # amount must be greater than or equal to 0
  validates :date, presence: true

  after_destroy :increase_investment_amount
  # before_save :adjust_investment_amount
  after_save :adjust_investment_amount

  # can not do this, as will override the value from frontend
  # after_initialize :set_date_today, :if => :new_record?

  def net_cash
    @net_cash ||= (gross_profit + return_of_capital - (withholding_tax + (holdback_state || 0) + (cash_reserve || 0)))
  end

  private

  def increase_investment_amount
    investment.amount += return_of_capital
    investment.save!
  end

  # def adjust_investment_amount
  #   investment.amount -= return_of_capital
  #   investment.save!

  #   unless new_record?
  #     previous_investment = Investment.find(investment_id_was)
  #     previous_investment.amount += return_of_capital_was
  #     previous_investment.save!
  #   end
  # end

  def adjust_investment_amount
    UpdateInvestmentStatsWorker.perform_async(investment_id)
  end
end
