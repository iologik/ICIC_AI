# frozen_string_literal: true

class UpdateSubInvestmentStatsWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, on_conflict: :replace

  def perform(sub_investment_id)
    UpdateSubInvestmentStatsService.new.call(sub_investment_id)
  end
end
