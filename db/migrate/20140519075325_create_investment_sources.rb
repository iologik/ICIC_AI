# frozen_string_literal: true

class CreateInvestmentSources < ActiveRecord::Migration[5.2]
  def change
    create_table :investment_sources do |t|
      t.string :name
      t.integer :priority
      t.timestamps
    end
  end
end
