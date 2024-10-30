# frozen_string_literal: true

class CreateExchangeRates < ActiveRecord::Migration[5.2]
  def change
    create_table(:exchange_rates) do |t|
      t.date :date
      t.decimal :usd_to_cad_rate
      t.decimal :cad_to_usd_rate

      t.timestamps
    end
  end
end
