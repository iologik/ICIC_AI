# frozen_string_literal: true

class AddStatsColumnsToInvestment < ActiveRecord::Migration[6.0]
  def change
    add_sub_stats_fields
    add_distrib_stats_fields

    add_column :investments, :draw_amount, :decimal
    add_column :investments, :distribution_draw_amount, :decimal
  end

  def add_sub_stats_fields
    add_column :investments, :sub_amount_total, :decimal
    add_column :investments, :sub_ownership_percent_sum, :decimal
    add_column :investments, :sub_per_annum_sum, :decimal
    add_column :investments, :sub_accrued_percent_sum, :decimal
    add_column :investments, :sub_retained_percent_sum, :decimal
  end

  def add_distrib_stats_fields
    add_column :investments, :distrib_return_of_capital, :decimal
    add_column :investments, :distrib_withholding_tax, :decimal
    add_column :investments, :distrib_holdback_state, :decimal
    add_column :investments, :distrib_gross_profit, :decimal
    add_column :investments, :distrib_cash_reserve, :decimal
    add_column :investments, :distrib_net_cash, :decimal
  end
end
