# frozen_string_literal: true

class SetCorrectCurrentAmountForSubInvestments < ActiveRecord::Migration[5.2]
  def change
    active_investment_status_id = InvestmentStatus.active_status.id
    SubInvestment.find_each do |item|
      total_in = total_out = 0

      item.current_amount_steps.each do |step|
        total_in  += (step.in || 0)
        total_out += (step.out || 0)
      end

      item.update(amount: total_in - total_out)
      item.update(investment_status_id: active_investment_status_id) if (total_in - total_out).positive?
    end
  end
end
