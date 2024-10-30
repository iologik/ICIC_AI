# frozen_string_literal: true

class AlterAmountForSubInvestments < ActiveRecord::Migration[5.2]
  def up
    change_sub_investments_columns
    change_distributions_columns
    change_draws_columns
    change_investments_columns
    change_payments_columns
    change_sub_distributions_columns
    change_withdraws_columns
  end

  def change_sub_investments_columns
    change_column :sub_investments, :amount, :decimal, precision: 12, scale: 2
    change_column :sub_investments, :ori_amount, :decimal, precision: 12, scale: 2
    change_column :sub_investments, :referrand_one_time_amount, :decimal, precision: 12, scale: 2
  end

  def change_distributions_columns
    change_column :distributions, :return_of_capital, :decimal, precision: 12, scale: 2
    change_column :distributions, :gross_profit, :decimal, precision: 12, scale: 2
  end

  def change_draws_columns
    change_column :draws, :amount, :decimal, precision: 12, scale: 2
  end

  def change_investments_columns
    change_column :investments, :amount, :decimal, precision: 12, scale: 2
    change_column :investments, :ori_amount, :decimal, precision: 12, scale: 2
  end

  def change_payments_columns
    change_column :payments, :sub_investment_amount, :decimal, precision: 12, scale: 2
  end

  def change_sub_distributions_columns
    change_column :sub_distributions, :sub_investment_amount, :decimal, precision: 12, scale: 2
    change_column :sub_distributions, :amount, :decimal, precision: 12, scale: 2
    change_column :sub_distributions, :investment_amount, :decimal, precision: 12, scale: 2
  end

  def change_withdraws_columns
    change_column :withdraws, :amount, :decimal, precision: 12, scale: 2
  end

  def down; end
end
