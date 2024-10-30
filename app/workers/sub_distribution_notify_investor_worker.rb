# frozen_string_literal: true

class SubDistributionNotifyInvestorWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, on_conflict: :replace

  def perform(sub_distribution_id)
    SubDistributionNotifyInvestorService.new.call(sub_distribution_id)
  end
end
