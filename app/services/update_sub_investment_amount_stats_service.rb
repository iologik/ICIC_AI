# frozen_string_literal: true

class UpdateSubInvestmentAmountStatsService < BaseService
  attr_accessor :sub_investment

  def initialize(sub_investment_id)
    @sub_investment = SubInvestment.find(sub_investment_id)
  end

  def call
    update_current_accrued_retained

    UpdateInvestmentStatsWorker.perform_async(sub_investment.investment_id)
    UpdateSubInvestorAmountService.new(sub_investment.admin_user_id).call
  end

  def update_current_accrued_retained
    sub_investment.amount                  = sub_investment.current_amount
    sub_investment.current_accrued_amount  = sub_investment.current_accrued
    sub_investment.current_retained_amount = sub_investment.current_retained
    sub_investment.save
  end
end
