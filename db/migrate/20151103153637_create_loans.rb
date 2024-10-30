# frozen_string_literal: true

class CreateLoans < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table(:loans) do |t|
      t.belongs_to :borrower
      t.decimal :ori_amount, precision: 12, scale: 2
      t.decimal :amount, precision: 12, scale: 2
      t.date :start_date
      t.string :currency
      t.string :scheduled
      t.integer :months
      t.text :description

      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
