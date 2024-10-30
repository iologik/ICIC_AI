# frozen_string_literal: true

class AddFieldsToInvestment < ActiveRecord::Migration[6.0]
  def change
    add_column :investments, :money_raised_amount, :decimal, precision: 12, scale: 2
    add_column :investments, :cash_reserve_amount, :decimal, precision: 12, scale: 2
    add_column :investments, :cad_money_raised_amount, :decimal, precision: 12, scale: 2
  end
end
