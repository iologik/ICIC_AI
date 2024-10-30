# frozen_string_literal: true

class AddOtherStatsToInvestments < ActiveRecord::Migration[6.0]
  def change
    add_column :investments, :gross_profit_total_amount, :decimal
    add_column :investments, :all_paid_payments_amount, :decimal
    add_column :investments, :sub_balance_amount, :decimal
    add_column :investments, :net_income_amount, :decimal
  end
end
