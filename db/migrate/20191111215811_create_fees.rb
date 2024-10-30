# frozen_string_literal: true

class CreateFees < ActiveRecord::Migration[5.2]
  def change
    create_table :fees do |t|
      t.references :sub_investment
      t.references :investment
      t.string :description
      t.decimal :amount

      t.timestamps
    end
  end
end
