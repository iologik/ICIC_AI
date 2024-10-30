# frozen_string_literal: true

class UpdateSubInvestmentAmountStatsWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, on_conflict: :replace

  def perform(sub_investment_id)
    UpdateSubInvestmentAmountStatsService.new(sub_investment_id).call
  end
end
