# frozen_string_literal: true

class UpdateInvestmentStatsWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, on_conflict: :replace

  def perform(investment_id)
    UpdateInvestmentStatsService.new.call(investment_id)
  end
end
