# frozen_string_literal: true

class CreateInvestments < ActiveRecord::Migration[5.2]
  def change
    create_investments_table
    add_index :investments, :investment_kind_id
    add_index :investments, :investment_status_id
    add_index :investments, :investment_source_id
  end

  # rubocop:disable Metrics/MethodLength
  def create_investments_table
    create_table :investments do |t|
      t.string :name
      t.integer :investment_kind_id
      t.float :amount
      t.float :money_raised
      t.text :description
      t.string :image_url
      t.integer :investment_status_id
      t.float :exchange_rate
      t.integer :investment_source_id
      t.float :expected_return_percent

      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
