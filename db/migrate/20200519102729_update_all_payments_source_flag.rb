# frozen_string_literal: true

class UpdateAllPaymentsSourceFlag < ActiveRecord::Migration[5.2]
  def change
    Payment.find_each do |payment|
      next unless (investment_source = payment.sub_investment.investment.investment_source)

      payment.source_flag = investment_source.name
      payment.save
    end
  end
end
