# frozen_string_literal: true

class AddExchangeRateToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :exchange_rate, :integer
  end
end
