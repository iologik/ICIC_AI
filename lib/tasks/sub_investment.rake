# frozen_string_literal: true

namespace :sub_investment do
  task status: :environment do
    active_status = InvestmentStatus.active_status
    SubInvestment.all.each do |sub|
      sub.investment_status = active_status
      sub.save
    end
  end
end
