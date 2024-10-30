# frozen_string_literal: true

class CreateInvestmentKinds < ActiveRecord::Migration[5.2]
  def change
    create_table :investment_kinds do |t|
      t.string :name
      t.timestamps
    end
  end
end
