# frozen_string_literal: true

class UpdateSubInvestmentPaymentWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, on_conflict: :replace

  def perform(sub_investment_id)
    UpdateSubInvestmentPaymentService.new(sub_investment_id).call
  end
end
