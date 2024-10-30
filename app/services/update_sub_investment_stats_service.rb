# frozen_string_literal: true

class UpdateSubInvestmentStatsService < BaseService
  def call(sub_investment_id)
    UpdateSubInvestmentPaymentService.new(sub_investment_id).call
    UpdateSubInvestmentAmountStatsService.new(sub_investment_id).call
  end
end
