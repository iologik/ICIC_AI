# frozen_string_literal: true

class UpdateSubInvestorAmountService < BaseService
  attr_accessor :sub_investor

  def initialize(sub_investor_id)
    @sub_investor = AdminUser.find(sub_investor_id)
  end

  def call
    sub_investor.adjust_investment_amount
  end
end
