# frozen_string_literal: true

class UpdateDashboardStatsWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, on_conflict: :replace

  def perform
    UpdateDashboardStatsService.new.call
  end
end
