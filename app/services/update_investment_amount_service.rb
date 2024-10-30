# frozen_string_literal: true

class UpdateInvestmentAmountService < BaseService
  attr_accessor :investment

  def initialize(investment_id)
    @investment = Investment.find(investment_id)
  end

  def call
    investment.adjust_amount
  end
end
