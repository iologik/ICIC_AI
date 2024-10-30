# frozen_string_literal: true

class CreateDistributions < ActiveRecord::Migration[5.2]
  def change
    create_table :distributions do |t|
      t.decimal :return_of_capital
      t.decimal :gross_profit
      t.date :date
      t.text :description
      t.references :investment

      t.timestamps
    end
  end
end
