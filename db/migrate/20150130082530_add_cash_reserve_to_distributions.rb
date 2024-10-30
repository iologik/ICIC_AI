# frozen_string_literal: true

class AddCashReserveToDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :distributions, :cash_reserve, :decimal, precision: 12, scale: 2
  end
end
