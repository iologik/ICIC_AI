# frozen_string_literal: true

class DestroySubInvestmentService < BaseService
  attr_accessor :sub_investment

  def initialize(sub_investment_id)
    @sub_investment = SubInvestment.find(sub_investment_id)
  end

  def call
    sub_investor_id = sub_investment.admin_user_id

    delete_related_records

    UpdateSubInvestorAmountService.new(sub_investor_id).call
  end

  def delete_related_records
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("delete from payments where sub_investment_id=#{sub_investment.id}")
      ActiveRecord::Base.connection.execute("delete from withdraws where sub_investment_id=#{sub_investment.id}")
      ActiveRecord::Base.connection.execute("delete from interest_periods where sub_investment_id=#{sub_investment.id}")
      sub_investment.destroy
    end
  end
end
